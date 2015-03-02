require 'sinatra'
require 'twilio-ruby'
require 'evernote_oauth'
require 'open-uri'
require 'pp'

def dev_token
  # Pull dev token from environment
  @dev_token ||= ENV['EVERNOTE_DEV_TOKEN']
end

def client
  @client ||= EvernoteOAuth::Client.new(
    token: dev_token,
    sandbox: true
  )
end

def note_store
  @note_store ||= client.note_store
end

def notebooks
  @notebooks ||= note_store.listNotebooks(dev_token)
end

def make_note(note_store, note_title, note_text, resource, mime_type, notebook_name)
  notebook_guid = find_or_create_notebook(notebook_name)

  # Create note object
  new_note = Evernote::EDAM::Type::Note.new(
    title: note_title,
    notebookGuid: notebook_guid
  )

  hexdigest = new_note.add_resource('Attachment', resource, mime_type) if resource
  note_body = generate_note_body(note_text, hexdigest, mime_type)

  new_note.content = note_body

  create_note(new_note)
end

def find_or_create_notebook(notebook_name)
  if notebooks.any? {|notebook| notebook.name == notebook_name }
    # Notebook exists, get the notebook GUID
    notebook = notebooks.find { |nb| nb.name == notebook_name }
    notebook.guid
  else
    # Create notebook and store GUID
    notebook = Evernote::EDAM::Type::Notebook.new()
    notebook.name = notebook_name
    new_notebook = note_store.createNotebook(dev_token, notebook)
    new_notebook.guid
  end
end

def generate_note_body(note_text, resource_hexdigest, mime_type)
  note_body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  note_body += "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
  note_body += "<en-note>#{note_text} "
  note_body += "<en-media type='#{mime_type}' hash='#{resource_hexdigest}'/>" if resource_hexdigest
  note_body += "</en-note>"
end

def create_note(new_note)
  # Attempt to create note in Evernote account
  begin
    note = note_store.createNote(new_note)
  rescue Evernote::EDAM::Error::EDAMUserException => edue
    ## Something was wrong with the note data
    ## See EDAMErrorCode enumeration for error code explanation
    ## http://dev.evernote.com/documentation/reference/Errors.html#Enum_EDAMErrorCode
    pp "EDAMUserException: #{edue}"
    pp edue.errorCode
    pp edue.parameter
  rescue Evernote::EDAM::Error::EDAMNotFoundException => ednfe
    ## Parent Notebook GUID doesn't correspond to an actual notebook
    pp "EDAMNotFoundException: Invalid parent notebook GUID"
  end
end

def download_file(file_url)
  # Read content of file into memory and return it
  open(file_url).read
end

post '/message' do
  # If there's an attached image, download it
  image = download_file(params[:MediaUrl0]) if params[:NumMedia].to_i >= 1

  make_note note_store, 'From SMS', params[:Body], image, params[:MediaContentType0], "From Evernote-Twilio"
end

post '/voice' do
  content_type :xml

  Twilio::TwiML::Response.new do |r|
    r.Say 'Record a message to put in your default notebook.'
    r.Record :transcribeCallback => "http://brent.ngrok.com/transcription", :playBeep => "true"
  end.to_xml
end

post '/transcription' do
  sound = download_file(params[:RecordingUrl])

  make_note note_store, 'From voice call', params[:TranscriptionText], sound, "audio/mpeg", "From Evernote-Twilio"
end

require 'sinatra'
require 'twilio-ruby'
require "evernote_oauth"

def dev_token
  @dev_token ||= 'S=s1:U=90484:E=1528ed06b55:C=14b371f3ca8:P=1cd:A=en-devtoken:V=2:H=2e311c0746d91e1cafdc0d573d3b7a48'
end

def client
  @client ||= EvernoteOAuth::Client.new(token: dev_token, sandbox: true)
end

def note_store
  @note_store ||= client.note_store
end

def notebooks
  @notebooks ||= note_store.listNotebooks(dev_token)
end

def make_note(note_store, note_title, note_body, notebook_name)
  notebook_guid = ''

  if notebooks.any? {|notebook| notebook.name == notebook_name }
    # Notebook exists, get the notebook GUID
    twilio_notebook = notebooks.find { |nb| nb.name == notebook_name }
    notebook_guid = twilio_notebook.guid
  else
    # Create notebook and store GUID
    notebook = Evernote::EDAM::Type::Notebook.new()
    notebook.name = notebook_name
    new_notebook = note_store.createNotebook(dev_token, notebook)
    notebook_guid = new_notebook.guid
  end

  note_body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  note_body += "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
  note_body += "<en-note>#{note_body}</en-note>"

  # Create note object
  new_note = Evernote::EDAM::Type::Note.new
  new_note.title = note_title
  new_note.content = n_body
  new_note.notebookGuid = notebook_guid

  # Attempt to create note in Evernote account
  begin
    note = note_store.createNote(new_note)
  rescue Evernote::EDAM::Error::EDAMUserException => edue
    ## Something was wrong with the note data
    ## See EDAMErrorCode enumeration for error code explanation
    ## http://dev.evernote.com/documentation/reference/Errors.html#Enum_EDAMErrorCode
    pp "EDAMUserException: #{edue}"
    pp edue.errorCode
  rescue Evernote::EDAM::Error::EDAMNotFoundException => ednfe
    ## Parent Notebook GUID doesn't correspond to an actual notebook
    pp "EDAMNotFoundException: Invalid parent notebook GUID"
  end
end

-- load the smtp support and its friends
local smtp = require("smtp")
local mime = require("mime")
local ltn12 = require("ltn12")

-- creates a source to send a message with two parts. The first part is 
-- plain text, the second part is a PNG image, encoded as base64.
source = smtp.message{
  headers = {
     -- Remember that headers are *ignored* by smtp.send. 
     from = "Sicrano <sicrano@tecgraf.puc-rio.br>",
     to = "Fulano <fulano@tecgraf.puc-rio.br>",
     subject = "Here is a message with attachments"
  },
  body = {
    preamble = "If your client doesn't understand attachments, \r\n" ..
               "it will still display the preamble and the epilogue.\r\n",
               "Preamble might show up even in a MIME enabled client.",
    -- first part: No headers means plain text, us-ascii.
    -- The mime.eol low-level filter normalizes end-of-line markers.
    [1] = { 
      body = mime.eol(0, [[
        Lines in a message body should always end with CRLF. 
        The smtp module will *NOT* perform translation. It will
        perform necessary stuffing, though.
     ]])
    },
    -- second part: Headers describe content the to be an image, 
    -- sent under the base64 transfer content encoding.
    -- Notice that nothing happens until the message is sent. Small 
    -- chunks are loaded into memory and translation happens on the fly.
    [2] = { 
      headers = {
        ["content-type"] = 'image/png; name="image.png"',
        ["content-disposition"] = 'attachment; filename="image.png"',
        ["content-description"] = 'a beautiful image',
        ["content-transfer-encoding"] = "BASE64"
      },
      body = ltn12.source.chain(
        ltn12.source.file(io.open("image.png", "rb")),
        ltn12.filter.chain(
          mime.encode("base64"),
          mime.wrap()
        )
      )
    },
    epilogue = "This might also show up, but after the attachments"
  }
}

-- finally send it
r, e = smtp.send{
    rcpt = "<diego@cs.princeton.edu>",
    from = "<diego@cs.princeton.edu>",
    source = source,
    server = "mail.cs.princeton.edu"
}
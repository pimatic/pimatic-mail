pimatic mail plugin
=======================


Provides an action handler to send mails from pimatic rules. It uses 
 [nodemailer v0.7](https://github.com/andris9/Nodemailer/blob/0.7/README.md) which supports all common mail transports.

Configuration
-------------
You can load the backend by editing your `config.json` to include:

    {
      "plugin": "mail",
      "transport": "SMTP",
      "transportOptions": {
        "service": "Gmail", // sets automatically host, port and connection security settings
        "auth": {
            "user": "gmail.user@gmail.com",
            "pass": "userpass"
        }
      },
      "to": "gmail.user@gmail.com"
    }

in the `plugins` section. For all configuration options see [mail-config-schema](mail-config-schema.html). The 
 transport options are transport dependent and listed at 
 [nodemailer v0.7](https://github.com/andris9/Nodemailer/blob/0.7/README.md),

Usage
-----

Currently, you can send mail messages as part of rule actions. The "send mail" action supports the following 
modifiers:

* **to**: the mail recipient's address
* **from**: the mail sender's address
* **text**: an ASCII test string to be used as e-mail body text. If, both, **text** and **html** modifiers are 
 absent, the default text will be used as defined by the the plugin configuration.
* **html**: a HTML text string to be used as e-mail HTML body text. Id, both, **text** and **html** modifiers are 
 present, an e-mail with a multi-part body will be generated containing the plain text and the HTML text.
* **file**: a path to a file which will be attached to the e-mail. 


Example
-------

    IF it is 08:00 THEN send mail to:"gmail.user@gmail.com" subject:"Good morning!" text:"Good morning Dave!"

Credits
-------

<div>Icon made by <a href="http://www.unocha.org" title="OCHA">OCHA</a> is licensed under 
 <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>


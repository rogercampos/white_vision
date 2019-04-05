# WhiteVision

White Vision is a simple email platform to provide your application with basic emailing capabilities. It works as a mountable Engine on your ruby on rails application and provides a UI as well as a programmable API to perform operations.

The goal of this tool is to provide you with a way to create and send emails, as well as a way to keep track of emailing activity. You can define a *success rule* for any email sent (like opening, or clicking some specific link) and then know which ones of the sent emails are a success. All other related events are also recorded (email received, opened, clicked, etc.). But nothing more, for example, you won't be able to define "entire emailing flows". Instead you can do that on your own and use this tool just to send the emails at the correct time, calculated by you.

This tool uses Sendgrid as the underlaying email provider, using its [events webhooks](https://sendgrid.com/docs/API_Reference/Event_Webhook/event.html) to know about activity.


## Sendgrid Integration

As mentioned, you'll need a Sendgrid account to work with WhiteVision. At the time of writing, you can get a free account and send up to 100 emails per day. 

The configuration needed will be the **sendgrid_api_key**, and you'll have to configure a webhook in sendgrid pointing to `/white_vision/sendgrid_event_callback` in order to capture events. You can follow sendgrid's reference [here](https://sendgrid.com/docs/API_Reference/Event_Webhook/getting_started_event_webhook.html) to set it up.

You can set the api key with:

```ruby
# initializers/white_vision.rb or a file of your choice 
WhiteVision::Config.sendgrid_api_key = "api key"
```
 
If you choose to use basic auth security in sendgrid, you can give the user and password to WhiteVision this way:

```ruby
WhiteVision::Config.webhook_basic_auth_username = "user"
WhiteVision::Config.webhook_basic_auth_password = "passwd"
```

## Using the programmable API

The api you can use to send emails is:

```ruby
WhiteVision::Sender.send_email recipient: "foobar@gmail.com",
                               subject: "Subject line",
                               format: :html,
                               message: "<h1>Hi!</h1>",
                               from: "Myself <myself@me.com>",
                               track_success: true, 
                               success_rule: "by_open"
```

This provides a fine grained control level, as you explicitly give all information for the email to be sent. Arguments are:

- recipient: Required. A string or array of strings with the recipient emails.
- cc: Optional. A string or array of strings with emails to be included as "cc".
- bcc: Optional. A string or array of strings with emails to be included as "bcc".
- subject: Required. String that will appear as the subject of the sent email.
- format: Required. A symbol either `:html` or `:text`. The format of the email.
- message: Required. A string with the body of the email. Either an html string or a plain text depending on format.
- from: Required. A string with the email acting as sender.
- template_id: Optional. A string identifier to make this email part of a group. Only for reporting purposes. If this is an ad-hoc email, you can leave it blank. If this email is part of a campaign you're sending to many users, then you can use this to group all those emails together and get reports based on that.  
- track_success: Required. Boolean indicating whether or not success should be tracked for this email.
- success_rule: Required only if track_success. A string either "by_click" or "by_open", indicating what to account as a success for this email. "by_open" will track success as soon as the email is open (as tacked by sendgrid, it uses a 1px image for that) and "by_click" will track success when any link in the email is clicked.
- success_url_regexp: Optional. If `success_rule` is "by_click" and this is provided (as a string), the success will only count if the clicked url matches this value interpreted as a regexp. If the value is not a valid regexp, an error will be raised.
- extra_data: Optional. A hash of data with additional information to be saved along with this email. Used only for reporting purposes later on, for example, you can store here your user's id to identify the recipient by your own terms, or any additional information to help identify this email by itself or as a member of a group later on. It will be stored as json, so the data must be compatible (only basic types).


Instead of using this low level api, however, is usually preferable to define the emails your application will send as ruby classes. This gem comes with a way for you to do that that provides:

- Interpolations of values. Transform `=my_var=` in the email's body into actual values you provide.
- A simple way to store html templates of the emails
- The option to show a preview of those emails in the admin UI.


```ruby
class NewPost < WhiteVision::HtmlEmail
  def initialize(post)
    @post = post
    @post_url = "https://mywebsite/#{@post.slug}" # Simplified!
  end
  
  def subject
    "[My website] New post - #{@post.title}"
  end
  
  def track_success?
    true
  end

  def success_rule
    'by_click'
  end

  def success_url_regexp
    Regexp.escape(@post_url)
  end
  
  def html_template
    'new_post.html'
  end
  
  def replacements
    {
      "=post_title=" => @post.title
    }
  end
end
```

- `format` will be automatically set to `:html`.
- The `template_id` explained before will be automatically inferred from the class name. You can also define that method to override this behavior.
- `message` will be constructed by loading the template you specified in the `html_template` method. This gem will look for that file in the folder `<Rails.root>/app/views/white_vision/<name>`. Can have subfolders, like `posts/new_post.html`. If you want to store those templates in another place, you can say so with `WhiteVision::Config.html_templates_root = "/my/path"`. You can also override `message` with your own implementation, it just needs to return the HTML of the email to be sent.
- The same arguments explained in the API of the `send_email` method before are here considered methods of the email class. You can define any such method and it will take precedence. Exceptions are "recipient", "cc" and "bcc", since you'll provide those later on when sending the email.
- The `replacements` is an optional hash with pairs of "key => value" with all the substitutions that will have to be performed on the email message. This is automatically applied in the email template, but you can also manually apply it with the method `apply_replacements(string)`. For example, if the subject is dynamic, you could make it include the recipients' name with:


```ruby
class NewPost < WhiteVision::HtmlEmail
  def initialize(post, user)
    @post = post
    @post_url = "https://mywebsite/#{@post.slug}" # Simplified!
    @user = user # The recipient of the email
  end
  
  def subject
    # Ex: The subject is dynamic, is set when creating a new post.
    # Suppose it has the value "Hi =name=, a new post has been published!", after
    # applying replacements it will be "Hi Jon, a new post has been published!"  
    apply_replacements(@post.email_subject)  
  end
  
  def replacements
    {
      "=name=" => @user.name
    }
  end
end
```

The value of each replacement can be either the raw string value, or a lambda, in which case it will be `call`ed at runtime. This may be convenient to combine with `apply_replacements("value", except: "=subject=") for example, to exclude some replacements to be taken into account. For example, if you want to provide the subject of the email as a replacement globally for each email, but for one particular email you want the subject to be also computed taking into account replacements. You would normally define subject as we seen before like:


```ruby
  def subject
    apply_replacements(@post.email_subject)  
  end
``` 

But if `subject` is also mentioned as part of a generic replacements, this will lead into an infinite loop:

```ruby
def replacements
  { "=subject=" => subject, # others ...}
end
```

The way to avoid that would be call `apply_replacements` excluding the subject replacement when you call if from `subject` itself, as well as defining the generic subject replacement as lazy with a proc:

```ruby
  def subject
    apply_replacements(@post.email_subject, except: "=subject=")  
  end
  
  def replacements
    { "=subject=" => -> { subject } }
  end
``` 



If you want to create a text email instead, you can inherit from `WhiteVision::TextEmail`:

```ruby
class NewPost < WhiteVision::TextEmail
  def initialize(post)
    @post = post
    @post_url = "https://mywebsite/#{@post.slug}" # Simplified!
  end
  
  def subject
    "[My website] New post - #{@post.title}"
  end
  
  def track_success?
    true
  end

  def success_rule
    'by_click'
  end

  def success_url_regexp
    Regexp.escape(@post_url)
  end
  
  def message
    "This is the email body"
  end
  
  def replacements
    {
      "=post_title=" => @post.title
    }
  end
end
```  

Same as before, except this time you must provide the email body yourself as `message`. You can use `apply_replacements` if needed.  

You can then send such emails with:

```ruby
email = NewPost.new(Post.last)
WhiteVision::Sender.send_email_template email, recipient: "foo@gmail.com" # "cc" and "bcc" also optional
```

## Using the UI

Using the UI you can create email templates to later on send emails to recipients. Creating an email template is a 2-step process. 

First you create it as a draft, where data can be imcomplete. In this state you can provide test values for substitutions, check the resulting email in the browser and perform a test send (but for real) to a test recipient as configured from the code.

Contrary to the programmable usage, options are more limited here, as can be expected. It works by providing the following config from the app:


```ruby
# config/initializers/white_vision.rb
  
Config.recipient_klass = Subscriber
Config.recipient_klass_attribute = :email
Config.testing_only_recipients = ["roger@rogercampos.com"]
Config.send_scopes = {
  active_list: -> (rel) { rel.active.not_bounced },
  premium_list: -> (rel) { rel.premium }
}
Config.substitutions = {
  '=name=' => proc { |subscriber| subscriber.name },
  '=cancelation_url=' => proc { |subscriber| Rails.routes.cancel_url(tk: subsciber.cancel_token) }
}
Config.default_from = "Me Myself <me@me.com>"

```

- `recipient_klass` will be an AR class that holds your representation of a possible "recipient". Maybe a dedicated class like `Subscriber` or a more general thing like `User`. 
- The `recipient_klass_attribute` is the attribute from that class that's expected to hold the real recipient to deliver to (note this can be a ruby method, not a db column). 
- The `testing_only_recipients` will be the allowed recipients to send test emails during testing phase. 
- The `send_scopes` will be the possible "collections" to send the real email later on. 
- And finally the `substitutions` will be the set of optional substitutions your emails can contain, passing a lambda to each one to calculate the final value from an instance of the given `recipient_klass`.


When you're confident about the draft, you can promote it to "finished". Now the template cannot be further edited (nor deleted), and you can now deliver it to any of the "sending scopes" defined in the config. When you no longer need an email template, you can "archive" it, it won't bother you anymore.

Using the UI you can only sent "context-less" emails to recipients, so it must be a pretty simple thing. Things like generic campaigns or offers, or adhoc messages. For doing more complex things like "I noticed you have this product in the cart and I want you to finish your order, showing you the exact product" or more context-aware things like that, you must use the programmable API. 
 
In the UI you can also previsualize the emails created in the app, but with no substitutions.

"template_id"'s cannot be repeated, so we will validate them at creation time and also at the time an email is sent (it may be possible that you use a given template_id in an email created from the UI and later on you reuse the same one from an email hardcoded in the app. In this case, an error will be raised when you'll try to send an email with that template.) 




## Reporting



## Email previews

Already explained for emails created ad-hoc via UI. For programatic emails created as ruby classes, you need to create the class method `initiailze_preview` in your email class, and return an instance of that email. Initialize with fake data as you see fit. For example:

 
```ruby
class NewPost < WhiteVision::HtmlEmail
  def initialize(post, user)
    @post = post
    @user = user
  end
  
  # All other email methods
 
  def self.initialize_preview
    new Post.first, User.first # or whatever 
  end
end
```

If this method is not present or returns nil, the preview won't be available for this email.


## Testing helpers

This gem offers some already made helpers to facilitate the task to test sent emails in your tests. 

If using Minitest, you should include this module in your `TestCase`:

```ruby
module ActiveSupport
  class TestCase
    include WhiteVision::MinitestHelpers
  end
end
```

Or if using rspec, declare it in a support file:

```ruby
# spec/support/white_vision.rb
 
RSpec.configure do |config|
  config.include(WhiteVision::RspecHelpers)
end 
```

This module offers the following methods:

- ........................


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'white_vision'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install white_vision
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

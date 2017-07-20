# Redmine Send Issue Reply Email

[![Build Status](https://travis-ci.org/matsukei/redmine_send_issue_reply_email.svg?branch=master)](https://travis-ci.org/matsukei/redmine_send_issue_reply_email)

It is a plugin that provides the email sending feature to non Redmine users when registering notes.

## Usage

1. Check the `Manage email delivery setting` checkbox on the `Administrator > Roles and permissions > Roles > Permissions > Send issue reply email` .
2. Check the `Send issue reply email` checkbox on the `Projects > Settings > Modules` .
3. Input the `Projects > Settings > Send issue reply email` .
    * See: http://www.redmine.org/projects/redmine/wiki/EmailConfiguration
4. If you want to send the contents of the notes by email when editing the issue, check `Send a email` .
5. If you input To and Cc and submit it, Send a email.
    * For the issue registered or updated via email, the corresponding email address has been inputted in advance.
    * Even if you forget to input the issue_id in the subject, the project and issue_id are okay because they are attached to the email header.

## Notes

* Setting to create and update issues by receiving email.
  * See: http://www.redmine.org/projects/redmine/wiki/RedmineReceivingEmails
* If you want to encrypt the password you entered, register `database_cipher_key` in `your_redmine_path/config/configuration.yml` .
  * When registering or changing `database_cipher_key`, Please enter the password again later.
  * If you are already registering SCM or LDAP password, please carefully read the notes in `your_redmine_path/config/configuration.yml`, such as by running `rake db:encrypt RAILS_ENV=production` .

## Screenshot

*Projects > Settings > Send issue reply email*

![project_setting_send_issue_reply_email](https://user-images.githubusercontent.com/943541/27818657-95d6ffc8-60d1-11e7-8cae-2da184934c9d.png)

*Issue edit*

![issue_edit](https://user-images.githubusercontent.com/943541/27818683-a4b072ea-60d1-11e7-9ac7-515bdd03bb71.png)

## Install

1. git clone or copy an unarchived plugin to plugins/redmine_send_issue_reply_email on your Redmine path.
2. `$ cd your_redmine_path`
3. `$ bundle install`
4. `$ bundle exec rake redmine:plugins:migrate NAME=redmine_send_issue_reply_email RAILS_ENV=production`
5. web service restart

## Uninstall

1. `$ cd your_redmine_path`
2. `$ bundle exec rake redmine:plugins:migrate NAME=redmine_send_issue_reply_email RAILS_ENV=production VERSION=0`
3. remove plugins/redmine_send_issue_reply_email
4. web service restart

## Dependency

Tags Input: https://github.com/xoxco/jQuery-Tags-Input

## License

[The MIT License](https://opensource.org/licenses/MIT)

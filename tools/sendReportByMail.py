import os
import smtplib
import mimetypes
from email.message import EmailMessage


def sendMail():
    message = EmailMessage()
    sender = os.environ['USER_EMAIL']
    recipient = os.environ['USER_EMAIL']
    message['From'] = sender
    message['To'] = recipient
    message['Subject'] = 'Analyze of target over'
    body = """Hello;
    You can find the html report in attachement."""
    message.set_content(body)
    mime_type, _ = mimetypes.guess_type('report.html')
    mime_type, mime_subtype = mime_type.split('/')
    with open('report.html', 'r') as file:
        message.add_attachment(file.read(),
                               maintype=mime_type,
                               subtype=mime_subtype,
                               filename='urls.txt')
        mail_server = smtplib.SMTP_SSL('smtp.gmail.com')
        mail_server.login(os.environ['USER_EMAIL'], os.environ['USER_PASSWORD'])
        mail_server.send_message(message)
        mail_server.quit()
    print('(DEBUG) Sending report to the user by mail: OK')


if __name__ == "__main__":
    sendMail()

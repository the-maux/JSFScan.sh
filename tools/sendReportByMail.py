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
    username = os.environ['USER_EMAIL']
    password = os.environ['USER_PASSWORD']
    with open('report.html', 'r') as file:  # TODO parse if the mail was sent
        message.add_attachment(file.read(), subtype=mime_subtype, filename='urls.txt')
        mail_server = smtplib.SMTP_SSL('smtp.gmail.com')
        mail_server.login(username, password)
        retour_mail = mail_server.send_message(message)
        print(f'Server SMTP result status : {retour_mail}')
        mail_server.quit()
        print('(DEBUG) Sending report to the user by mail: OK')
        exit(0)
    print('(DEBUG) Sending report to the user by mail: KO')
    exit(-1)


if __name__ == "__main__":
    sendMail()

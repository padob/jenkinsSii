$ mkdir ssh
$ cd ssh

$ openssl genrsa -out key.pem

----------------
$ openssl req -new -key key.pem -out csr.pem
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:PL
State or Province Name (full name) []:
Locality Name (eg, city) [Default City]:KRK
Organization Name (eg, company) [Default Company Ltd]:Sii
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:192.168.1.8
Email Address []:admin@xyz.pl

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:

----------------
$ openssl x509 -req -days 9999 -in csr.pem -signkey key.pem -out cert.pem
Signature ok
subject=/C=PL/L=KRK/O=Sii/CN=192.168.1.8/emailAddress=admin@xyz.pl
Getting Private key


Add to command line
--httpsPort=8443 --httpsCertificate=$jh/ssh/cert.pem --httpsPrivateKey=$jh/ssh/key.pem
--httpPort=-1


https://github.com/hughperkins/howto-jenkins-ssl

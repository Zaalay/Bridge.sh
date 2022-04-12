# Bridge.sh
Bridge UNIX systems

## How to install
You can simply run
```
curl -sS https://raw.githubusercontent.com/Zaalay/Bridge.sh/alpha/install.sh | bash
```
and boom! You got it installed! :D

## How to upgrade
You can either run
```
bridgesh-upgrade
```
or
```
bridgesh-update
```
Yeah, they're the same things

## How to uninstall
Just run
```
bridgesh-uninstall
```
And... goodbye...

## How to debug
Well, you can just clone this repo, enter the directory, and run
```
./install.sh -t
```

### Wanna test it on local network as well?
Just run
```
python3 -m http.server
```
And then you can run this command on any UNIX devices in the same network
as yours. BTW, you might need to open a new terminal
```
curl -sS http://YOUR-SERVER-IP:8000/install.sh | bash -s -- -t http://YOUR-SERVER-IP:8000
```
Don't forget to replace "YOUR-SERVER-IP" with your literal IP!

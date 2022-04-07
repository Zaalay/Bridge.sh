# Bridge.sh
Bridge UNIX systems

## How to install
You can simply run
```
curl -sS https://raw.githubusercontent.com/Zaalay/Bridge.sh/alpha/install.sh | bash
```
and boom! You got it installed! :D

## How to debug
Well, you can just clone this repo, enter the directory, and run
```
python3 -m http.server
```
And then you can run this command on any UNIX devices in the same network
as yours
```
curl -sS http://YOUR-SERVER-IP:8000/install.sh | bash -s -- -t http://YOUR-SERVER-IP:8000
```
Don't forget to replace "YOUR-SERVER-IP" with your literal IP!


### Just wanna test it locally?
Then you can simply run
```
./install.sh -t
```

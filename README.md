cloudflare-dns-manager
======================

A simple script written in bash to manage DNS Zones using Cloudflare API to make a DDNS service for your machine. 

This script relies on the utility written by _stedolan_.

Go [here](https://github.com/unnikked/cloudflare-dns-manager.git) and install first his utility, otherwise the script will not work.

# How to use

First of all you need to have a domain configured with CloudFlare. 

Go to the [Account Section](https://www.cloudflare.com/my-account) and grab your __API KEY__.

With this script you can __CREATE__, __MODIFY__ or __DELETE__ any type or DNS record (i.e _A_, _CNAME_, _MX_ etc.).

## Syntax

- _email_ : your cloudflare account email
- _token_ : your cloudflare apy key
- _domain_ : your domain name
- _action_ : __CREATE__, __MODIFY__ or __DELETE__
- _type_ : _A_, _CNAME_, _MX_ etc.
- _zonename_ : the value of your record (example.domain.com)
- _servicemode_ : if you want to enable CDN feature of cloudflare (0 - disable, 1 - enabled)

### Examples

- `./dyndns.sh your@email.com tokenid domain.com CREATE A example.domain.com 0`
- `./dyndns.sh your@email.com tokenid domain.com MODIFY A example.domain.com 0`
- `./dyndns.sh your@email.com tokenid domain.com DELETE A example.domain.com 0`

The script will automatically retrieve your machine IP and add to the request. 

Setting a cron with this script will automatically refresh your machine IP if your dinamic IP changes. 

`*/5 * * * * /path/to/the/script/dyndns.sh your@email.com tokenid domain.com MODIFY A example.domain.com 0`

Every 5 minutes this commands will fire causing an update of your A record if your local machine IP changes. 

## Bugs

I have not fully tested the script, I only tested it with an A record, if you find any bug please open an issue.

### Why I've done this ?

To enjoy myself and to learn some inner aspects of bash. 

# Licence

         DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                   Version 2, December 2004

Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

Everyone is permitted to copy and distribute verbatim or modified
copies of this license document, and changing it is allowed as long
as the name is changed.

           DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
  TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

 0. You just DO WHAT THE FUCK YOU WANT TO.

# Disclaimer

THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

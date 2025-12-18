# Quick NPM Fix Checklist

## Access NPM
1. Open browser: http://145.223.73.242:81
2. Login: cyberspacebusinessceo@gmail.com / tZHTy71TiWaA1d9lE07GLsz8OYF

## Critical Fixes (Do These First!)

### For EVERY proxy host, check these 2 things:

#### 1. Details Tab - Scheme
| Service | Scheme |
|---------|--------|
| n8n | **http** |
| grafana | **http** |
| portainer | **https** ⚠️ |
| prometheus | **http** |
| uptime | **http** |
| starhawk | **https** ⚠️ |
| moxie | **http** |
| cadvisor | **http** |
| proxmox | **https** ⚠️ |

**Most common mistake:** Using `https` when it should be `http`

#### 2. SSL Tab
**EVERY service must have:**
- ✅ Force SSL: **ON**
- ✅ HTTP/2 Support: **ON**

## Websocket Support Needed For:
- ✅ n8n
- ✅ portainer
- ✅ uptime
- ✅ starhawk
- ✅ proxmox

## Special Cases

### Portainer (if getting SSL errors)
Advanced Tab:
```nginx
proxy_ssl_verify off;
```

### Proxmox (if getting 504 timeout)
Advanced Tab:
```nginx
proxy_ssl_verify off;
proxy_read_timeout 3600;
proxy_connect_timeout 3600;
proxy_send_timeout 3600;
```

### n8n (if workflows failing)
Advanced Tab:
```nginx
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
proxy_read_timeout 86400;
client_max_body_size 50M;
```

## After Each Change
Click **Save** and test in browser!

## Common Errors Fixed

| Error | Fix |
|-------|-----|
| "Dangerous site" warning | Enable "Force SSL" |
| 502 Bad Gateway | Check scheme (http vs https) |
| 504 Gateway Timeout | Add timeout configs (see Proxmox above) |
| Websocket disconnects | Enable "Websockets Support" |
| SSL errors | Add `proxy_ssl_verify off;` |

## Quick Test
Open in browser (should NOT see errors):
- https://n8n.cyberspace.business
- https://grafana.cyberspace.business
- https://portainer.cyberspace.business

## Automation Option
Instead of manual fixes, run:
```powershell
.\FIX_NPM_NOW.ps1
```
Or on Linux/Mac:
```bash
bash fix_npm_config.sh
```

This updates all settings automatically via the database.

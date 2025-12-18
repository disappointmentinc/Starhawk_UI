# NPM Configuration Fix Guide

Your Nginx Proxy Manager (NPM) has configuration issues causing the following problems:
- "Dangerous site" warnings (HTTP/HTTPS scheme mismatch)
- 504 Gateway Timeout errors (missing proxy timeouts)
- Connection failures (missing websocket support)

## Quick Summary of Issues

The main problems are:
1. **Wrong scheme**: Services using `https` when they should use `http` (or vice versa)
2. **Missing websockets**: Services like n8n, Portainer, Proxmox need websocket support enabled
3. **Missing SSL verify off**: Services with self-signed certs (Portainer, Proxmox) need SSL verification disabled
4. **Missing timeouts**: Proxmox needs longer connection timeouts

## Choose Your Fix Method

### Option 1: Automatic Fix (RECOMMENDED)

**From Windows PowerShell:**
```powershell
cd C:\code_pretending\starhawk_ui
.\FIX_NPM_NOW.ps1
```

**From Linux/Mac or SSH on server:**
```bash
cd /path/to/scripts
bash fix_npm_config.sh
```

This will:
- Backup your NPM database
- Fix all proxy host settings automatically
- Restart NPM
- Test all services

**Time: 2-3 minutes**

---

### Option 2: Manual Fix via Web UI

1. Open NPM: http://145.223.73.242:81
2. Login: cyberspacebusinessceo@gmail.com / tZHTy71TiWaA1d9lE07GLsz8OYF
3. Go to "Hosts" → "Proxy Hosts"
4. Follow the checklist in `QUICK_FIX_CHECKLIST.md`

**Time: 10-15 minutes**

---

### Option 3: Diagnose First, Then Fix

Run the diagnostic script to see what's wrong:
```bash
bash diagnose_npm.sh
```

This will show you:
- Current configuration for each service
- What's misconfigured
- Whether backend services are running
- HTTP status codes for each domain

Then choose Option 1 or 2 to fix.

---

## Critical Settings Per Service

| Service | Scheme | Port | Websockets | Special Config |
|---------|--------|------|------------|----------------|
| n8n | `http` | 5678 | ✅ Yes | Long timeout, large uploads |
| grafana | `http` | 3000 | ❌ No | Standard config |
| portainer | `https` ⚠️ | 9443 | ✅ Yes | SSL verify off |
| prometheus | `http` | 9090 | ❌ No | Standard config |
| uptime | `http` | 3001 | ✅ Yes | Websocket headers |
| starhawk | `https` ⚠️ | 21371 | ✅ Yes | SSL verify off |
| moxie | `http` | 1372 | ❌ No | Standard config |
| cadvisor | `http` | 8080 | ❌ No | Standard config |
| proxmox | `https` ⚠️ | 8006 | ✅ Yes | SSL verify off + long timeouts |

⚠️ = Uses HTTPS to backend (most services use HTTP!)

---

## Common Errors & Fixes

### "This site can't provide a secure connection" / ERR_SSL_PROTOCOL_ERROR
**Cause:** Scheme is set to `https` but backend service uses `http`
**Fix:** Change scheme to `http` in NPM proxy host settings

### 504 Gateway Timeout (especially Proxmox)
**Cause:** Connection timeout too short
**Fix:** Add to Advanced config:
```nginx
proxy_read_timeout 3600;
proxy_connect_timeout 3600;
proxy_send_timeout 3600;
```

### Websocket disconnects (n8n workflows fail, Uptime Kuma doesn't update)
**Cause:** Websocket support not enabled
**Fix:** Enable "Websockets Support" checkbox in Details tab

### 502 Bad Gateway
**Cause:** Backend service not running OR wrong scheme
**Fix:**
1. Check if service is running: `docker ps | grep <service>`
2. Verify scheme (http vs https)

---

## Files Provided

| File | Purpose |
|------|---------|
| `fix_npm_config.sh` | Bash script to auto-fix all NPM configs |
| `FIX_NPM_NOW.ps1` | PowerShell script to run fix remotely from Windows |
| `diagnose_npm.sh` | Diagnostic script to check current config |
| `QUICK_FIX_CHECKLIST.md` | Manual fix checklist for web UI |
| `COMPLETE_NPM_FIX_GUIDE.md` | Full detailed guide (reference) |

---

## Testing After Fix

### Quick Browser Test
Open these URLs - you should see login pages (not errors):
- https://n8n.cyberspace.business
- https://grafana.cyberspace.business
- https://portainer.cyberspace.business
- https://proxmox.cyberspace.business

### Command Line Test
```bash
curl -I https://n8n.cyberspace.business
# Should return: HTTP/2 200 or 302 (NOT 502, 504)
```

---

## Troubleshooting

### "bash: fix_npm_config.sh: command not found"
You need to run it ON the server (Starhawk), not locally:
```bash
ssh root@145.223.73.242
# Then run the script
bash /path/to/fix_npm_config.sh
```

### "Connection refused" when accessing NPM
NPM might not be running:
```bash
docker ps | grep nginx-proxy-manager
docker start nginx-proxy-manager
```

### Services still not working after fix
1. Check if backend service is running:
   ```bash
   docker ps | grep <service-name>
   ```
2. Check service logs:
   ```bash
   docker logs <service-container-name>
   ```
3. Run diagnostic script:
   ```bash
   bash diagnose_npm.sh
   ```

---

## Support

If you still have issues:
1. Run `diagnose_npm.sh` and share the output
2. Check NPM logs: `docker logs nginx-proxy-manager`
3. Check specific service logs: `docker logs <service-name>`

---

## Reference: NPM Database Location

NPM stores config in: `/data/database.sqlite` (inside the container)

The fix script modifies this database directly, which is why NPM needs to be restarted after.

---

**Ready to fix? Run:**
```powershell
.\FIX_NPM_NOW.ps1
```

# PTR Record vs A Record - Format Guide

## Forward Zone (A Records)
- **Zone Example**: `dionipe.id.`
- **User Input**: `www`
- **Full Record Name**: `www.dionipe.id.`
- **Content**: IP address (e.g., `192.168.1.100`)
- **Purpose**: Maps domain name → IP address

## Reverse Zone (PTR Records)
- **Zone Example**: `214.142.103.in-addr.arpa.`
- **User Input**: Last octet of IP (e.g., `10` for IP `103.142.214.10`)
- **Full Record Name**: `10.214.142.103.in-addr.arpa.`
- **Content**: Fully qualified domain name (e.g., `mail.dionipe.id.`)
- **Purpose**: Maps IP address → domain name

## Key Differences

### IP Address Format
- **Forward Zone**: Enter the IP in normal format (e.g., `192.168.1.100`)
- **Reverse Zone**: Enter the IP in reverse notation:
  - IP `103.142.214.10` → enters as `10.214.142.103.in-addr.arpa.`
  - But user only types the **last octet** (`10`), system adds the zone suffix

### Content Format
- **Forward Zone (A Record)**: Enter IP address directly
  - Example: `192.168.1.100`
  - Example: `2001:db8::1` (for AAAA)

- **Reverse Zone (PTR Record)**: Enter FQDN (with trailing dot)
  - Example: `mail.dionipe.id.`
  - Example: `web.dionipe.net.`

## How the System Works

### Adding A Record to `dionipe.id.` zone
1. User enters name: `www`
2. User enters content: `192.168.1.100`
3. System creates: `www.dionipe.id.` (A record) → `192.168.1.100`

### Adding PTR Record to `214.142.103.in-addr.arpa.` zone
1. User enters name: `10` (last octet of IP 103.142.214.10)
2. User enters content: `mail.dionipe.id.` (FQDN with trailing dot)
3. System creates: `10.214.142.103.in-addr.arpa.` (PTR) → `mail.dionipe.id.`

## Example Usage

### Scenario: Add reverse DNS for IP 103.142.214.25

**Step 1**: Click zone `214.142.103.in-addr.arpa.`

**Step 2**: Click "Add Record" button

**Step 3**: Fill the form:
- **Record Name**: `25`
- **Record Type**: `PTR`
- **TTL**: `3600`
- **Content**: `webserver.dionipe.id.`

**Result**: The system creates PTR record
- **Name**: `25.214.142.103.in-addr.arpa.`
- **Type**: `PTR`
- **Content**: `webserver.dionipe.id.`

This allows reverse DNS lookups: IP `103.142.214.25` → `webserver.dionipe.id.`

## Common Mistakes

❌ **Wrong**: Entering full IP in reverse zone
- Input: `103.142.214.25` 
- This would create: `103.142.214.25.214.142.103.in-addr.arpa.` (INCORRECT)

✅ **Correct**: Entering only last octet in reverse zone
- Input: `25`
- This creates: `25.214.142.103.in-addr.arpa.` (CORRECT)

❌ **Wrong**: Entering content without trailing dot
- Input: `webserver.dionipe.id`
- This is incomplete and may not work properly

✅ **Correct**: Entering content with trailing dot
- Input: `webserver.dionipe.id.`
- Fully qualified domain name (FQDN)

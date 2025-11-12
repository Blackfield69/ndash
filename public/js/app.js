// NDash PowerDNS Dashboard - Main JavaScript

// Utility functions
const Utils = {
  // Format number with thousands separator
  formatNumber(num) {
    return new Intl.NumberFormat().format(num);
  },
  
  // Format date
  formatDate(date) {
    return new Intl.DateTimeFormat('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    }).format(new Date(date));
  },
  
  // Debounce function
  debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  },
  
  // Copy to clipboard
  async copyToClipboard(text) {
    try {
      await navigator.clipboard.writeText(text);
      this.showNotification('Copied to clipboard!', 'success');
    } catch (err) {
      console.error('Failed to copy:', err);
      this.showNotification('Failed to copy', 'error');
    }
  },
  
  // Show notification (simple implementation)
  showNotification(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `fixed top-4 right-4 px-6 py-3 rounded-lg shadow-lg toast ${
      type === 'success' ? 'bg-green-500 text-white' :
      type === 'error' ? 'bg-red-500 text-white' :
      'bg-blue-500 text-white'
    }`;
    toast.textContent = message;
    document.body.appendChild(toast);
    
    setTimeout(() => {
      toast.style.opacity = '0';
      setTimeout(() => toast.remove(), 300);
    }, 3000);
  },
  
  // Validate domain name
  isValidDomain(domain) {
    const pattern = /^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$/i;
    return pattern.test(domain);
  },
  
  // Validate IP address
  isValidIP(ip) {
    const pattern = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
    return pattern.test(ip);
  }
};

// API Client
const API = {
  baseUrl: '/api',
  
  async request(method, path, data = null) {
    const options = {
      method,
      headers: {
        'Content-Type': 'application/json'
      }
    };
    
    if (data) {
      options.body = JSON.stringify(data);
    }
    
    try {
      const response = await fetch(`${this.baseUrl}${path}`, options);
      
      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || 'Request failed');
      }
      
      return await response.json();
    } catch (error) {
      console.error('API Error:', error);
      throw error;
    }
  },
  
  // Server methods
  async getServers() {
    return this.request('GET', '/servers');
  },
  
  // Zone methods
  async getZones(serverId) {
    return this.request('GET', `/servers/${serverId}/zones`);
  },
  
  async getZone(serverId, zoneId) {
    return this.request('GET', `/servers/${serverId}/zones/${zoneId}`);
  },
  
  async createZone(serverId, zoneData) {
    return this.request('POST', `/servers/${serverId}/zones`, zoneData);
  },
  
  async deleteZone(serverId, zoneId) {
    return this.request('DELETE', `/servers/${serverId}/zones/${zoneId}`);
  },
  
  async updateRecords(serverId, zoneId, rrsets) {
    return this.request('PATCH', `/servers/${serverId}/zones/${zoneId}`, rrsets);
  },
  
  // Statistics methods
  async getStatistics(serverId) {
    return this.request('GET', `/servers/${serverId}/statistics`);
  }
};

// Record type helpers
const RecordTypes = {
  types: [
    'A', 'AAAA', 'CNAME', 'MX', 'NS', 'TXT', 'SRV', 
    'PTR', 'SOA', 'CAA', 'TLSA', 'DS', 'DNSKEY'
  ],
  
  getDescription(type) {
    const descriptions = {
      'A': 'IPv4 Address',
      'AAAA': 'IPv6 Address',
      'CNAME': 'Canonical Name',
      'MX': 'Mail Exchange',
      'NS': 'Name Server',
      'TXT': 'Text Record',
      'SRV': 'Service Record',
      'PTR': 'Pointer Record',
      'SOA': 'Start of Authority',
      'CAA': 'Certification Authority Authorization',
      'TLSA': 'TLS Authentication',
      'DS': 'Delegation Signer',
      'DNSKEY': 'DNS Key'
    };
    return descriptions[type] || type;
  },
  
  validate(type, content) {
    switch (type) {
      case 'A':
        return Utils.isValidIP(content);
      case 'AAAA':
        return /^([0-9a-f]{0,4}:){7}[0-9a-f]{0,4}$/i.test(content);
      case 'CNAME':
      case 'NS':
      case 'PTR':
        return Utils.isValidDomain(content) || content.endsWith('.');
      case 'MX':
        return /^\d+\s+.+/.test(content);
      case 'TXT':
        return content.length > 0;
      default:
        return true;
    }
  }
};

// Export for use in Alpine components
window.Utils = Utils;
window.API = API;
window.RecordTypes = RecordTypes;

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
  console.log('NDash PowerDNS Dashboard loaded');
  
  // Refresh Lucide icons periodically for dynamically added content
  const observer = new MutationObserver(() => {
    if (typeof lucide !== 'undefined') {
      lucide.createIcons();
    }
  });
  
  observer.observe(document.body, {
    childList: true,
    subtree: true
  });
});

// Handle navigation
window.addEventListener('navigate', (e) => {
  console.log('Navigate to:', e.detail);
  // Implement client-side routing if needed
});

// Keyboard shortcuts
document.addEventListener('keydown', (e) => {
  // Ctrl/Cmd + K for search
  if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
    e.preventDefault();
    // Implement search functionality
    console.log('Search shortcut triggered');
  }
  
  // Escape to close modals
  if (e.key === 'Escape') {
    // Dispatch event for Alpine components to handle
    window.dispatchEvent(new CustomEvent('close-modal'));
  }
});

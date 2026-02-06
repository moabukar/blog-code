const express = require('express');
const app = express();

const PORT = process.env.PORT || 8080;

/**
 * Extract user identity from IAP-injected headers
 * Supports: Pomerium, OAuth2-Proxy, GCP IAP
 */
function getUserFromHeaders(req) {
    // Try different header formats
    let email = req.headers['x-forwarded-email'] || 
                req.headers['x-auth-request-email'] ||
                req.headers['x-goog-authenticated-user-email'];
    
    if (!email) {
        return null;
    }

    // GCP IAP format: "accounts.google.com:user@example.com"
    if (email.includes(':')) {
        email = email.split(':')[1];
    }

    // Parse groups
    const groupsHeader = req.headers['x-forwarded-groups'] || 
                         req.headers['x-auth-request-groups'] || '';
    
    const groups = groupsHeader
        .split(',')
        .map(g => g.trim())
        .filter(Boolean);

    return { email, groups };
}

/**
 * Middleware: Require authentication
 */
function requireAuth(req, res, next) {
    const user = getUserFromHeaders(req);
    
    if (!user) {
        console.log(`Unauthorized request to ${req.path}`);
        return res.status(401).json({ error: 'Unauthorized' });
    }

    console.log(`Request from user: ${user.email}, groups: ${user.groups.join(',')}, path: ${req.path}`);
    req.user = user;
    next();
}

/**
 * Middleware factory: Require specific group
 */
function requireGroup(group) {
    return (req, res, next) => {
        const user = getUserFromHeaders(req);
        
        if (!user) {
            return res.status(401).json({ error: 'Unauthorized' });
        }

        if (!user.groups.includes(group)) {
            console.log(`Access denied for ${user.email}: requires ${group}, has ${user.groups.join(',')}`);
            return res.status(403).json({ error: `Forbidden: requires group ${group}` });
        }

        req.user = user;
        next();
    };
}

/**
 * Middleware factory: Require any of the specified groups
 */
function requireAnyGroup(groups) {
    return (req, res, next) => {
        const user = getUserFromHeaders(req);
        
        if (!user) {
            return res.status(401).json({ error: 'Unauthorized' });
        }

        const hasGroup = user.groups.some(g => groups.includes(g));
        
        if (!hasGroup) {
            console.log(`Access denied for ${user.email}: requires one of ${groups.join(',')}, has ${user.groups.join(',')}`);
            return res.status(403).json({ error: 'Forbidden' });
        }

        req.user = user;
        next();
    };
}

// Health check (no auth required)
app.get('/health', (req, res) => {
    res.json({ status: 'healthy' });
});

// Public endpoint
app.get('/', (req, res) => {
    const user = getUserFromHeaders(req);
    
    if (user) {
        res.json({
            message: 'Welcome!',
            authenticated: true,
            user
        });
    } else {
        res.json({
            message: 'Welcome! (not authenticated)',
            authenticated: false
        });
    }
});

// User info endpoint
app.get('/api/me', requireAuth, (req, res) => {
    res.json(req.user);
});

// Data endpoint
app.get('/api/data', requireAuth, (req, res) => {
    res.json({
        data: ['item1', 'item2', 'item3'],
        accessed_by: req.user.email
    });
});

// Admin endpoint
app.get('/api/admin', requireGroup('admin'), (req, res) => {
    res.json({
        message: 'Admin-only endpoint',
        admin: req.user.email
    });
});

// Engineering endpoint
app.get('/api/engineering', 
    requireAnyGroup(['engineering', 'platform-team', 'sre']), 
    (req, res) => {
        res.json({
            message: 'Engineering data',
            user: req.user.email,
            groups: req.user.groups
        });
    }
);

// Debug endpoint - shows IAP headers
app.get('/debug/headers', requireAuth, (req, res) => {
    const relevantHeaders = {};
    
    for (const [name, value] of Object.entries(req.headers)) {
        const lowerName = name.toLowerCase();
        if (lowerName.startsWith('x-forwarded') ||
            lowerName.startsWith('x-auth') ||
            lowerName.startsWith('x-goog')) {
            relevantHeaders[name] = value;
        }
    }
    
    res.json(relevantHeaders);
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({ error: 'Not found' });
});

// Error handler
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

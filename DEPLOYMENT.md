# NextGIS Web Deployment Guide for Portainer

## Overview

This guide explains how to deploy NextGIS Web with a completely customized design using Docker Compose and Portainer.

## Prerequisites

- Docker installed on your server
- Portainer installed and accessible
- At least 4GB RAM and 2 CPU cores recommended
- PostgreSQL with PostGIS support

## Quick Start

### Option 1: Deploy via Portainer UI

1. **Login to Portainer**
   - Navigate to your Portainer instance
   - Select your environment

2. **Create a Stack**
   - Go to "Stacks" in the left menu
   - Click "Add stack"
   - Name it `nextgisweb`

3. **Deploy from Git Repository** (Recommended)
   - Choose "Repository" as the build method
   - Repository URL: `https://github.com/your-org/nextgisweb-deployment.git`
   - Or use local compose file upload

4. **Configure Environment Variables**
   - Copy `.env.example` to `.env`
   - Customize the following critical variables:
     ```bash
     DB_PASSWORD=your-secure-password
     SECRET_KEY=your-random-secret-key
     ADMIN_PASSWORD=change-this-immediately
     BRANDING_PRIMARY_COLOR=#your-brand-color
     ```

5. **Deploy the Stack**
   - Click "Deploy the stack"
   - Wait for all services to become healthy (may take 2-3 minutes)

### Option 2: Deploy via Docker Compose CLI

```bash
# Copy environment file
cp .env.example .env

# Edit environment variables
nano .env

# Deploy with docker-compose
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f nextgisweb-app
```

## Customization

### Changing Colors and Branding

1. **Edit CSS Theme**
   - Modify `customization/css/custom-theme.css`
   - Change CSS variables in the `:root` section
   - Key variables:
     - `--primary`: Main brand color
     - `--secondary`: Background color
     - `--accent`: Highlight color
     - `--danger`: Error color
     - `--success`: Success color

2. **Change Logo**
   - Replace `customization/assets/logo.svg` with your logo
   - Recommended size: 200x50 pixels
   - Format: SVG or PNG

3. **Update Environment Variables**
   ```bash
   BRANDING_PRIMARY_COLOR=#ff6b6b
   BRANDING_SECONDARY_COLOR=#4ecdc4
   BRANDING_ACCENT_COLOR=#ffe66d
   BRANDING_LOGO_TEXT=My GIS Platform
   ```

### Advanced Design Changes

The custom theme includes:

- **Typography**: Font families, weights, and sizes
- **Colors**: Complete color scheme customization
- **Borders**: Border radius for rounded corners
- **Shadows**: Depth and elevation effects
- **Components**: Buttons, cards, tables, forms, modals
- **Responsive**: Mobile-friendly adjustments
- **Dark Mode**: Optional dark theme support

### Adding Custom Assets

Place custom files in:
- `customization/assets/` - Logos, favicons, images
- `customization/css/` - Additional stylesheets
- `customization/js/` - Custom JavaScript (if needed)

## Portainer-Specific Configuration

### Resource Limits

The stack includes resource limits in the `deploy` section:

```yaml
deploy:
  resources:
    limits:
      cpus: '4.0'
      memory: 4G
    reservations:
      cpus: '1.0'
      memory: 1G
```

Adjust based on your server capacity.

### Health Checks

All services include health checks:
- Database: PostgreSQL readiness
- Application: HTTP endpoint availability
- Proxy: Nginx configuration

### Volumes

Persistent data is stored in named volumes:
- `nextgisweb-db-data`: PostgreSQL database
- `nextgisweb-data`: Application data and uploads
- `nextgisweb-assets`: Static assets and customizations

## Maintenance

### Backup

```bash
# Backup database
docker exec nextgisweb-db pg_dump -U nextgisweb nextgisweb > backup.sql

# Backup data volume
docker run --rm \
  -v nextgisweb-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/data-backup.tar.gz /data
```

### Restore

```bash
# Restore database
cat backup.sql | docker exec -i nextgisweb-db psql -U nextgisweb nextgisweb

# Restore data
docker run --rm \
  -v nextgisweb-data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/data-backup.tar.gz -C /data
```

### Update

```bash
# Pull latest images
docker-compose pull

# Recreate containers
docker-compose up -d

# Remove old images
docker image prune -f
```

### Logs

```bash
# View all logs
docker-compose logs -f

# View specific service
docker-compose logs -f nextgisweb-app

# Last 100 lines
docker-compose logs --tail=100 nextgisweb-app
```

## Troubleshooting

### Application Won't Start

1. Check database connection:
   ```bash
   docker-compose logs nextgisweb-db
   docker-compose logs nextgisweb-app
   ```

2. Verify environment variables:
   ```bash
   docker-compose config
   ```

3. Check database health:
   ```bash
   docker exec nextgisweb-db pg_isready
   ```

### Design Not Applied

1. Clear browser cache
2. Verify CSS file is loaded:
   ```bash
   docker exec nextgisweb-app ls -la /var/nextgisweb/customization/css/
   ```
3. Check application logs for CSS loading errors

### Performance Issues

1. Increase resource limits in `docker-compose.yml`
2. Enable nginx caching for static assets
3. Consider adding Redis for session management
4. Optimize database with proper indexes

## Security Recommendations

1. **Change Default Passwords**
   - Admin password immediately after first login
   - Database password in `.env`
   - Secret key for sessions

2. **Enable HTTPS**
   - Uncomment HTTPS section in `nginx/nginx.conf`
   - Add SSL certificates to `ssl/` directory
   - Use Let's Encrypt or your CA

3. **Firewall Rules**
   - Only expose necessary ports
   - Use Portainer's access control
   - Restrict database access

4. **Regular Updates**
   - Keep Docker images updated
   - Monitor security advisories
   - Apply patches promptly

## Support

- Documentation: https://docs.nextgis.com
- Community Forum: https://community.nextgis.com
- GitHub Issues: https://github.com/nextgis/nextgisweb/issues

## License

NextGIS Web is released under GPL v3.0 license.

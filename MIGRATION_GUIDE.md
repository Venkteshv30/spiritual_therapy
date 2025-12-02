# Database Migration Guide

## ✅ Tables Created Successfully

All tables from your Prisma schema have been created in the `hospital-mgmt` Docker PostgreSQL database.

### Created Tables:
1. **User** - User accounts with roles and membership tiers
2. **Guru** - Guru profiles linked to users
3. **Session** - Therapy sessions requested by users
4. **Meeting** - Video meeting details with Agora integration
5. **Attendance** - User attendance tracking for meetings

### Created Enums:
- `Role` - USER, GURU, ADMIN, HELPDESK, GUEST
- `MembershipTier` - FREE, SILVER, GOLD, PREMIUM
- `SessionStatus` - PENDING, APPROVED, REJECTED, COMPLETED

## Database Connection

**Docker Container:** `hospital-mgmt`  
**Database:** `spiritual_therapy`  
**Connection String:** `postgresql://postgres:password@localhost:5432/spiritual_therapy?schema=public`

## Environment Variables

Make sure your `.env` file contains:
```env
DATABASE_URL="postgresql://postgres:password@localhost:5432/spiritual_therapy?schema=public"
PORT=3000
NODE_ENV=development
AUTH_ENABLED=false
```

## Future Migrations

### Option 1: Using SQL Scripts (Current Method)
1. Make changes to `prisma/schema.prisma`
2. Generate SQL using: `npx prisma migrate dev --create-only` (if Prisma 7 supports it)
3. Or manually create SQL script based on schema changes
4. Apply: `docker exec -i hospital-mgmt psql -U postgres -d spiritual_therapy < migration.sql`

### Option 2: Using Prisma Migrate (When Prisma 7 Config is Fixed)
Once Prisma 7 migration config is properly set up:
```bash
npx prisma migrate dev --name migration_name
```

### Option 3: Using Prisma DB Push (For Development)
```bash
npx prisma db push
```

## Verify Tables

Check tables:
```bash
docker exec hospital-mgmt psql -U postgres -d spiritual_therapy -c "\dt"
```

Check table structure:
```bash
docker exec hospital-mgmt psql -U postgres -d spiritual_therapy -c "\d \"User\""
```

## Notes

- The `create_tables.sql` file contains the complete schema
- All foreign keys and indexes have been created
- The database is ready for use with your Prisma Client


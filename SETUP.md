\# 🌿 Spiritual Therapy Backend - Complete Setup Guide



A step-by-step guide to set up your Node.js + TypeScript + PostgreSQL + Prisma backend from scratch.



---



\## 📋 Step 1: Create Project Structure



```bash

mkdir spiritual-therapy-backend

cd spiritual-therapy-backend

npm init -y

```



Create these folders:



```

spiritual-therapy-backend/

├── src/

│   ├── config/

│   ├── modules/

│   │   ├── auth/

│   │   ├── users/

│   │   ├── sessions/

│   │   ├── meetings/

│   │   ├── gurus/

│   │   └── admin/

│   ├── common/

│   ├── prisma/

│   ├── app.ts

│   └── server.ts

├── .env

├── .gitignore

├── package.json

└── tsconfig.json

```



---



\## 🚀 Step 2: Install Dependencies



```bash

\# Core dependencies

npm install express cors dotenv @prisma/client



\# Development dependencies

npm install -D typescript @types/node @types/express @types/cors ts-node nodemon prisma



\# Swagger for API docs

npm install swagger-ui-express swagger-jsdoc

npm install -D @types/swagger-ui-express

```



---



\## ⚙️ Step 3: Configuration Files



\### Update `package.json` scripts:



Add these scripts to your package.json:



```json

"scripts": {

&nbsp; "dev": "nodemon src/server.ts",

&nbsp; "build": "tsc",

&nbsp; "start": "node dist/server.js",

&nbsp; "prisma:generate": "prisma generate",

&nbsp; "prisma:migrate": "prisma migrate dev",

&nbsp; "prisma:studio": "prisma studio"

}

```



\### Create `tsconfig.json`:



```json

{

&nbsp; "compilerOptions": {

&nbsp;   "target": "ES2020",

&nbsp;   "module": "commonjs",

&nbsp;   "lib": \["ES2020"],

&nbsp;   "outDir": "./dist",

&nbsp;   "rootDir": "./src",

&nbsp;   "strict": true,

&nbsp;   "esModuleInterop": true,

&nbsp;   "skipLibCheck": true,

&nbsp;   "forceConsistentCasingInFileNames": true,

&nbsp;   "resolveJsonModule": true,

&nbsp;   "moduleResolution": "node"

&nbsp; },

&nbsp; "include": \["src/\*\*/\*"],

&nbsp; "exclude": \["node\_modules", "dist"]

}

```



\### Create `.env` file:



```bash

PORT=3000

NODE\_ENV=development

DATABASE\_URL="postgresql://postgres:password@localhost:5432/spiritual\_therapy?schema=public"

AUTH\_ENABLED=false

```



\### Create `.gitignore`:



```

node\_modules/

dist/

.env

\*.log

.DS\_Store

prisma/migrations/

```



---



\## 🗄️ Step 4: PostgreSQL Setup



\### Option A: Docker (Recommended)



Create `docker-compose.yml`:



```yaml

version: '3.8'

services:

&nbsp; postgres:

&nbsp;   image: postgres:15-alpine

&nbsp;   container\_name: spiritual\_therapy\_db

&nbsp;   restart: always

&nbsp;   environment:

&nbsp;     POSTGRES\_USER: postgres

&nbsp;     POSTGRES\_PASSWORD: password

&nbsp;     POSTGRES\_DB: spiritual\_therapy

&nbsp;   ports:

&nbsp;     - "5432:5432"

&nbsp;   volumes:

&nbsp;     - postgres\_data:/var/lib/postgresql/data



volumes:

&nbsp; postgres\_data:

```



Start it:



```bash

docker-compose up -d

```



\### Option B: Native Installation



\*\*macOS:\*\*

```bash

brew install postgresql@15

brew services start postgresql@15

createdb spiritual\_therapy

```



\*\*Ubuntu:\*\*

```bash

sudo apt update

sudo apt install postgresql postgresql-contrib

sudo systemctl start postgresql

sudo -u postgres createdb spiritual\_therapy

```



---



\## 📊 Step 5: Prisma Setup



\### Create `prisma/schema.prisma`:



```prisma

generator client {

&nbsp; provider = "prisma-client-js"

}



datasource db {

&nbsp; provider = "postgresql"

&nbsp; url      = env("DATABASE\_URL")

}



enum Role {

&nbsp; USER

&nbsp; GURU

&nbsp; ADMIN

&nbsp; HELPDESK

&nbsp; GUEST

}



enum MembershipTier {

&nbsp; FREE

&nbsp; SILVER

&nbsp; GOLD

&nbsp; PREMIUM

}



enum SessionStatus {

&nbsp; PENDING

&nbsp; APPROVED

&nbsp; REJECTED

&nbsp; COMPLETED

}



model User {

&nbsp; id               String          @id @default(uuid())

&nbsp; phoneNumber      String          @unique

&nbsp; email            String?         @unique

&nbsp; name             String

&nbsp; role             Role            @default(USER)

&nbsp; nakshatra        String?

&nbsp; dateOfBirth      DateTime?

&nbsp; profession       String?

&nbsp; city             String?

&nbsp; state            String?

&nbsp; country          String?

&nbsp; membershipTier   MembershipTier  @default(FREE)

&nbsp; membershipExpiry DateTime?

&nbsp; createdAt        DateTime        @default(now())

&nbsp; updatedAt        DateTime        @updatedAt

&nbsp; 

&nbsp; sessionsRequested Session\[]      @relation("SessionRequester")

&nbsp; attendances       Attendance\[]

&nbsp; guruProfile       Guru?

&nbsp; 

&nbsp; @@index(\[phoneNumber])

&nbsp; @@index(\[email])

}



model Guru {

&nbsp; id             String    @id @default(uuid())

&nbsp; userId         String    @unique

&nbsp; user           User      @relation(fields: \[userId], references: \[id])

&nbsp; bio            String?

&nbsp; specialization String?

&nbsp; isActive       Boolean   @default(true)

&nbsp; createdAt      DateTime  @default(now())

&nbsp; updatedAt      DateTime  @updatedAt

&nbsp; 

&nbsp; sessions       Session\[]

&nbsp; meetings       Meeting\[]

}



model Session {

&nbsp; id            String        @id @default(uuid())

&nbsp; title         String

&nbsp; description   String?

&nbsp; status        SessionStatus @default(PENDING)

&nbsp; requestedById String

&nbsp; requestedBy   User          @relation("SessionRequester", fields: \[requestedById], references: \[id])

&nbsp; assignedToId  String?

&nbsp; assignedTo    Guru?         @relation(fields: \[assignedToId], references: \[id])

&nbsp; scheduledAt   DateTime?

&nbsp; maxCapacity   Int           @default(50)

&nbsp; createdAt     DateTime      @default(now())

&nbsp; updatedAt     DateTime      @updatedAt

&nbsp; 

&nbsp; meeting       Meeting?

&nbsp; 

&nbsp; @@index(\[status])

&nbsp; @@index(\[requestedById])

}



model Meeting {

&nbsp; id               String      @id @default(uuid())

&nbsp; sessionId        String      @unique

&nbsp; session          Session     @relation(fields: \[sessionId], references: \[id])

&nbsp; guruId           String

&nbsp; guru             Guru        @relation(fields: \[guruId], references: \[id])

&nbsp; agoraChannelName String      @unique

&nbsp; agoraToken       String?

&nbsp; startTime        DateTime

&nbsp; endTime          DateTime?

&nbsp; duration         Int         @default(60)

&nbsp; maxUsers         Int         @default(50)

&nbsp; isActive         Boolean     @default(true)

&nbsp; createdAt        DateTime    @default(now())

&nbsp; updatedAt        DateTime    @updatedAt

&nbsp; 

&nbsp; attendances      Attendance\[]

&nbsp; 

&nbsp; @@index(\[agoraChannelName])

&nbsp; @@index(\[startTime])

}



model Attendance {

&nbsp; id        String    @id @default(uuid())

&nbsp; meetingId String

&nbsp; meeting   Meeting   @relation(fields: \[meetingId], references: \[id])

&nbsp; userId    String

&nbsp; user      User      @relation(fields: \[userId], references: \[id])

&nbsp; joinedAt  DateTime  @default(now())

&nbsp; leftAt    DateTime?

&nbsp; 

&nbsp; @@unique(\[meetingId, userId])

&nbsp; @@index(\[meetingId])

&nbsp; @@index(\[userId])

}

```



\### Initialize Prisma:



```bash

npx prisma generate

npx prisma migrate dev --name init

```



---



\## 🔧 Step 6: Create Core Files



\### `src/config/database.ts`:



```typescript

import { PrismaClient } from '@prisma/client';



const prisma = new PrismaClient({

&nbsp; log: \['query', 'error', 'warn'],

});



export default prisma;

```



\### `src/config/constants.ts`:



```typescript

export const PORT = process.env.PORT || 3000;

export const NODE\_ENV = process.env.NODE\_ENV || 'development';

export const AUTH\_ENABLED = process.env.AUTH\_ENABLED === 'true';



export const MEMBERSHIP\_LIMITS = {

&nbsp; FREE: { sessionsPerMonth: 2 },

&nbsp; SILVER: { sessionsPerMonth: 4 },

&nbsp; GOLD: { sessionsPerMonth: 10 },

&nbsp; PREMIUM: { sessionsPerMonth: -1 },

};

```



\### `src/server.ts`:



```typescript

import app from './app';

import { PORT } from './config/constants';

import prisma from './config/database';



const startServer = async () => {

&nbsp; try {

&nbsp;   await prisma.$connect();

&nbsp;   console.log('✅ Database connected');



&nbsp;   app.listen(PORT, () => {

&nbsp;     console.log(`🚀 Server: http://localhost:${PORT}`);

&nbsp;     console.log(`📚 Docs: http://localhost:${PORT}/api-docs`);

&nbsp;   });

&nbsp; } catch (error) {

&nbsp;   console.error('❌ Failed to start:', error);

&nbsp;   process.exit(1);

&nbsp; }

};



startServer();



process.on('SIGINT', async () => {

&nbsp; await prisma.$disconnect();

&nbsp; process.exit(0);

});

```



\### `src/app.ts`:



```typescript

import express from 'express';

import cors from 'cors';

import swaggerUi from 'swagger-ui-express';

import swaggerJsdoc from 'swagger-jsdoc';

import usersRoutes from './modules/users/users.routes';



const app = express();



app.use(cors());

app.use(express.json());



const swaggerOptions = {

&nbsp; definition: {

&nbsp;   openapi: '3.0.0',

&nbsp;   info: {

&nbsp;     title: 'Spiritual Therapy API',

&nbsp;     version: '1.0.0',

&nbsp;   },

&nbsp;   servers: \[{ url: 'http://localhost:3000' }],

&nbsp; },

&nbsp; apis: \['./src/modules/\*\*/\*.routes.ts'],

};



const swaggerSpec = swaggerJsdoc(swaggerOptions);

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));



app.get('/health', (req, res) => {

&nbsp; res.json({ status: 'OK', timestamp: new Date().toISOString() });

});



app.use('/api/users', usersRoutes);



export default app;

```



---



\## 📝 Step 7: Create Users Module



\### `src/modules/users/users.service.ts`:



```typescript

import prisma from '../../config/database';

import { User, Prisma } from '@prisma/client';



export const createUser = async (data: Prisma.UserCreateInput): Promise<User> => {

&nbsp; return await prisma.user.create({ data });

};



export const getAllUsers = async (): Promise<User\[]> => {

&nbsp; return await prisma.user.findMany({

&nbsp;   select: {

&nbsp;     id: true,

&nbsp;     name: true,

&nbsp;     email: true,

&nbsp;     phoneNumber: true,

&nbsp;     role: true,

&nbsp;     membershipTier: true,

&nbsp;     createdAt: true,

&nbsp;   },

&nbsp; });

};



export const getUserById = async (id: string): Promise<User | null> => {

&nbsp; return await prisma.user.findUnique({

&nbsp;   where: { id },

&nbsp;   include: { guruProfile: true },

&nbsp; });

};



export const updateUser = async (

&nbsp; id: string,

&nbsp; data: Prisma.UserUpdateInput

): Promise<User> => {

&nbsp; return await prisma.user.update({

&nbsp;   where: { id },

&nbsp;   data,

&nbsp; });

};

```



\### `src/modules/users/users.controller.ts`:



```typescript

import { Request, Response } from 'express';

import \* as UsersService from './users.service';



export const createUser = async (req: Request, res: Response) => {

&nbsp; try {

&nbsp;   const user = await UsersService.createUser(req.body);

&nbsp;   res.status(201).json({ success: true, data: user });

&nbsp; } catch (error: any) {

&nbsp;   res.status(400).json({ success: false, error: error.message });

&nbsp; }

};



export const getAllUsers = async (req: Request, res: Response) => {

&nbsp; try {

&nbsp;   const users = await UsersService.getAllUsers();

&nbsp;   res.json({ success: true, data: users });

&nbsp; } catch (error: any) {

&nbsp;   res.status(500).json({ success: false, error: error.message });

&nbsp; }

};



export const getUserProfile = async (req: Request, res: Response) => {

&nbsp; try {

&nbsp;   const user = await UsersService.getUserById(req.params.id);

&nbsp;   if (!user) {

&nbsp;     return res.status(404).json({ success: false, error: 'User not found' });

&nbsp;   }

&nbsp;   res.json({ success: true, data: user });

&nbsp; } catch (error: any) {

&nbsp;   res.status(500).json({ success: false, error: error.message });

&nbsp; }

};



export const updateUserProfile = async (req: Request, res: Response) => {

&nbsp; try {

&nbsp;   const user = await UsersService.updateUser(req.params.id, req.body);

&nbsp;   res.json({ success: true, data: user });

&nbsp; } catch (error: any) {

&nbsp;   res.status(400).json({ success: false, error: error.message });

&nbsp; }

};

```



\### `src/modules/users/users.routes.ts`:



```typescript

import { Router } from 'express';

import { createUser, getUserProfile, updateUserProfile, getAllUsers } from './users.controller';



const router = Router();



/\*\*

&nbsp;\* @swagger

&nbsp;\* /api/users:

&nbsp;\*   post:

&nbsp;\*     summary: Create a new user

&nbsp;\*     tags: \[Users]

&nbsp;\*     requestBody:

&nbsp;\*       required: true

&nbsp;\*       content:

&nbsp;\*         application/json:

&nbsp;\*           schema:

&nbsp;\*             type: object

&nbsp;\*             properties:

&nbsp;\*               phoneNumber:

&nbsp;\*                 type: string

&nbsp;\*               name:

&nbsp;\*                 type: string

&nbsp;\*               email:

&nbsp;\*                 type: string

&nbsp;\*     responses:

&nbsp;\*       201:

&nbsp;\*         description: User created

&nbsp;\*/

router.post('/', createUser);



/\*\*

&nbsp;\* @swagger

&nbsp;\* /api/users:

&nbsp;\*   get:

&nbsp;\*     summary: Get all users

&nbsp;\*     tags: \[Users]

&nbsp;\*/

router.get('/', getAllUsers);



/\*\*

&nbsp;\* @swagger

&nbsp;\* /api/users/{id}:

&nbsp;\*   get:

&nbsp;\*     summary: Get user by ID

&nbsp;\*     tags: \[Users]

&nbsp;\*/

router.get('/:id', getUserProfile);



/\*\*

&nbsp;\* @swagger

&nbsp;\* /api/users/{id}:

&nbsp;\*   put:

&nbsp;\*     summary: Update user

&nbsp;\*     tags: \[Users]

&nbsp;\*/

router.put('/:id', updateUserProfile);



export default router;

```



---



\## ▶️ Step 8: Run the Application



```bash

\# Copy environment

cp .env.example .env



\# Install dependencies

npm install



\# Generate Prisma Client

npx prisma generate



\# Run migrations

npx prisma migrate dev --name init



\# Start dev server

npm run dev

```



\### ✅ Access Your API:



\- \*\*Server:\*\* http://localhost:3000

\- \*\*Health:\*\* http://localhost:3000/health

\- \*\*Swagger:\*\* http://localhost:3000/api-docs

\- \*\*Prisma Studio:\*\* `npx prisma studio`



---



\## 🧪 Step 9: Test APIs



\### Create User (cURL):



```bash

curl -X POST http://localhost:3000/api/users \\

&nbsp; -H "Content-Type: application/json" \\

&nbsp; -d '{

&nbsp;   "phoneNumber": "+919876543210",

&nbsp;   "name": "John Doe",

&nbsp;   "email": "john@example.com",

&nbsp;   "nakshatra": "Ashwini",

&nbsp;   "profession": "Software Engineer"

&nbsp; }'

```



\### Get All Users:



```bash

curl http://localhost:3000/api/users

```



Or use \*\*Swagger UI\*\* at http://localhost:3000/api-docs



---



\## 🎯 Next Steps



1\. Build remaining modules (sessions, meetings, gurus, admin) using the same pattern

2\. Add authentication when needed (set AUTH\_ENABLED=true)

3\. Integrate Agora SDK for video sessions

4\. Deploy to production with AWS RDS



---



\## 💡 Quick Commands



```bash

npm run dev              # Start development

npx prisma studio        # Visual DB editor

npx prisma migrate dev   # Create migration

npm run build            # Build for production

npm start                # Run production build

```



---



\## 🐛 Troubleshooting



\*\*Port in use:\*\*

```bash

lsof -ti:3000 | xargs kill -9

```



\*\*Prisma issues:\*\*

```bash

npx prisma generate

npx prisma db push

```



\*\*TypeScript errors:\*\*

```bash

npm install -D @types/node @types/express

```


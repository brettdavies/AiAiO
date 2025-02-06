import * as dotenv from 'dotenv';
import * as path from 'path';

// Load environment variables based on NODE_ENV
const envFile = process.env.NODE_ENV === 'production'
    ? '.env.production'
    : '.env.development';

dotenv.config({
    path: path.resolve(__dirname, '..', envFile)
});

// Firebase project configuration
export const firebaseConfig = {
    projectId: process.env.FIREBASE_PROJECT_ID || 'reelai-ffe67',
    region: process.env.FIREBASE_REGION || 'us-central1',
} as const;

// Emulator configuration
export const emulatorConfig = {
    auth: {
        port: parseInt(process.env.FIREBASE_AUTH_EMULATOR_PORT || '9099', 10),
    },
    firestore: {
        port: parseInt(process.env.FIREBASE_FIRESTORE_EMULATOR_PORT || '8080', 10),
    },
    functions: {
        port: parseInt(process.env.FIREBASE_FUNCTIONS_EMULATOR_PORT || '5001', 10),
    },
    storage: {
        port: parseInt(process.env.FIREBASE_STORAGE_EMULATOR_PORT || '9199', 10),
    },
} as const;

// Development settings
export const developmentConfig = {
    loggingLevel: process.env.FIREBASE_LOGGING_LEVEL || 'debug',
    offlinePersistence: process.env.FIREBASE_OFFLINE_PERSISTENCE === 'true',
    cacheSizeMb: parseInt(process.env.FIREBASE_CACHE_SIZE_MB || '100', 10),
} as const;

// Validate required environment variables
const requiredEnvVars = [
    'FIREBASE_PROJECT_ID',
    'FIREBASE_REGION',
    'FIREBASE_AUTH_EMULATOR_PORT',
    'FIREBASE_FIRESTORE_EMULATOR_PORT',
    'FIREBASE_FUNCTIONS_EMULATOR_PORT',
    'FIREBASE_STORAGE_EMULATOR_PORT',
];

requiredEnvVars.forEach(envVar => {
    if (!process.env[envVar]) {
        throw new Error(`Missing required environment variable: ${envVar}`);
    }
}); 
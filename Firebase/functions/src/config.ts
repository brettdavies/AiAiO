import * as dotenv from 'dotenv';
import * as path from 'path';

// Load environment variables based on NODE_ENV
const envFile = process.env.NODE_ENV === 'production'
    ? '.env.production'
    : '.env.development';

dotenv.config({
    path: path.resolve(__dirname, '..', envFile)
});

export const config = {
    region: process.env.FUNCTION_REGION || 'us-central1',
    runtimeOpts: {
        memory: process.env.FUNCTION_MEMORY || '256MB',
        timeoutSeconds: parseInt(process.env.FUNCTION_TIMEOUT_SECONDS || '60', 10),
    },
    minInstances: parseInt(process.env.MIN_INSTANCES || '0', 10),
    maxInstances: process.env.MAX_INSTANCES === 'auto'
        ? 'auto'
        : parseInt(process.env.MAX_INSTANCES || '0', 10)
} as const;

// Validate required environment variables
const requiredEnvVars = [
    'FUNCTION_REGION',
    'FUNCTION_MEMORY',
    'FUNCTION_TIMEOUT_SECONDS',
    'MIN_INSTANCES',
    'MAX_INSTANCES'
];

requiredEnvVars.forEach(envVar => {
    if (!process.env[envVar]) {
        throw new Error(`Missing required environment variable: ${envVar}`);
    }
}); 
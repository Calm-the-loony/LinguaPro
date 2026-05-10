const isProduction = window.location.hostname !== 'localhost' && 
                     window.location.hostname !== '127.0.0.1';

// В production запросы идут через nginx (relative path)
export const api = isProduction ? '/api' : 'http://localhost:5000/api';
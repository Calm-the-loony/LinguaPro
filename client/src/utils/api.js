const isProduction = window.location.hostname !== 'localhost' && 
                     window.location.hostname !== '127.0.0.1';

export const api = isProduction 
    ? 'https://омен.ru/api'    // тут поменять нада
    : 'http://localhost:5000/api';
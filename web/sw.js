// Service Worker for Bir Damla Kan PWA
const CACHE_NAME = 'bir-damla-kan-v1.0.2';
const urlsToCache = [
  '/',
  '/index.html',
  '/manifest.json',
  '/favicon.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  // Add other static assets as needed
];

// Install event
self.addEventListener('install', function(event) {
  console.log('Service Worker: Installing...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(function(cache) {
        console.log('Service Worker: Caching app shell');
        return cache.addAll(urlsToCache);
      })
      .then(function() {
        console.log('Service Worker: Skip waiting on install');
        return self.skipWaiting();
      })
  );
});

// Activate event
self.addEventListener('activate', function(event) {
  console.log('Service Worker: Activating...');
  event.waitUntil(
    caches.keys().then(function(cacheNames) {
      return Promise.all(
        cacheNames.map(function(cacheName) {
          if (cacheName !== CACHE_NAME) {
            console.log('Service Worker: Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(function() {
      console.log('Service Worker: Claiming clients');
      return self.clients.claim();
    })
  );
});

// Fetch event
self.addEventListener('fetch', function(event) {
  event.respondWith(
    caches.match(event.request)
      .then(function(response) {
        // Return cached version or fetch from network
        if (response) {
          console.log('Service Worker: Serving from cache:', event.request.url);
          return response;
        }
        
        return fetch(event.request).then(function(response) {
          // Check if we received a valid response
          if (!response || response.status !== 200 || response.type !== 'basic') {
            return response;
          }

          // Clone the response
          var responseToCache = response.clone();

          caches.open(CACHE_NAME)
            .then(function(cache) {
              cache.put(event.request, responseToCache);
            });

          return response;
        }).catch(function() {
          // Return offline page for navigation requests
          if (event.request.destination === 'document') {
            return caches.match('/index.html');
          }
        });
      })
  );
});

// Background sync for blood requests
self.addEventListener('sync', function(event) {
  if (event.tag === 'blood-request-sync') {
    console.log('Service Worker: Background sync for blood requests');
    event.waitUntil(syncBloodRequests());
  }
});

// Push notifications
self.addEventListener('push', function(event) {
  console.log('Service Worker: Push notification received');
  
  const options = {
    body: event.data ? event.data.text() : 'Yeni kan talebi mevcut!',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-72.png',
    vibrate: [200, 100, 200],
    tag: 'blood-request',
    actions: [
      {
        action: 'view',
        title: 'Görüntüle',
        icon: '/icons/Icon-192.png'
      },
      {
        action: 'close',
        title: 'Kapat'
      }
    ]
  };

  event.waitUntil(
    self.registration.showNotification('Bir Damla Kan', options)
  );
});

// Notification click handler
self.addEventListener('notificationclick', function(event) {
  console.log('Service Worker: Notification clicked');
  
  event.notification.close();

  if (event.action === 'view') {
    event.waitUntil(
      clients.openWindow('/#/blood-requests')
    );
  }
});

// Helper functions
function syncBloodRequests() {
  return fetch('/api/blood-requests')
    .then(response => response.json())
    .then(data => {
      console.log('Service Worker: Blood requests synced');
      return data;
    })
    .catch(error => {
      console.error('Service Worker: Sync failed', error);
    });
}
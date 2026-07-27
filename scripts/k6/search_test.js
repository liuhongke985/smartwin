import http from 'k6/http';
import { check, sleep } from 'k6';
import { SharedArray } from 'k6/data';

export let options = {
  scenarios: {
    search: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '1m', target: 200 },
        { duration: '5m', target: 200 },
        { duration: '1m', target: 0 },
      ],
      exec: 'searchScenario'
    },
    api: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '1m', target: 100 },
        { duration: '5m', target: 100 },
        { duration: '1m', target: 0 },
      ],
      exec: 'apiScenario'
    }
  },
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.01']
  }
};

const BASE = __ENV.BASE_URL || 'http://localhost:9000/api/smartdata';

let terms = new SharedArray('terms', function() {
  return ['客户','订单','产品','用户','交易','日志','行为','账户','地区','组织'];
});

export function searchScenario() {
  let term = terms[Math.floor(Math.random() * terms.length)];
  let res = http.get(`${BASE}/catalog/search?q=${encodeURIComponent(term)}&page=1&size=20`);
  check(res, { 'search status 200': (r) => r.status === 200 });
  sleep(Math.random() * 1.5);
}

export function apiScenario() {
  // get metadata by id (random id simulated)
  let id = Math.floor(Math.random() * 1000000);
  let res = http.get(`${BASE}/metadata/${id}`);
  check(res, { 'meta status 200': (r) => r.status === 200 || r.status === 404 });
  sleep(Math.random() * 1);
}

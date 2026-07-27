#!/usr/bin/env python3
"""
生成示例资产数据（JSON Lines），用于 Elasticsearch bulk 导入。
用法: python3 gen_assets.py --count 1000000 --out assets.jsonl
"""
import argparse
import json
import random
import uuid
from datetime import datetime

TERMS = ['客户','订单','产品','用户','交易','日志','行为','账户','地区','组织']
TAGS = ['金融','电商','运营','分析','私有','公共']


def gen_record(i):
    doc = {
        "asset_id": str(uuid.uuid4()),
        "name": f"资产_{i}_{random.choice(TERMS)}",
        "description": "示例资产，用于压测",
        "source": random.choice(['mysql','hive','api','file']),
        "tags": random.sample(TAGS, k=random.randint(1,2)),
        "quality_score": round(random.uniform(0.5, 1.0), 3),
        "created_at": datetime.utcnow().isoformat() + 'Z',
        "fields_count": random.randint(10,30)
    }
    return doc


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--count', type=int, default=10000)
    p.add_argument('--out', type=str, default='assets.jsonl')
    args = p.parse_args()

    with open(args.out, 'w', encoding='utf-8') as f:
        for i in range(args.count):
            # ES bulk indexing line format: {"index":{}}\n{doc}\n
            meta = {"index": {"_id": i}}
            f.write(json.dumps(meta, ensure_ascii=False) + '\n')
            f.write(json.dumps(gen_record(i), ensure_ascii=False) + '\n')

    print(f"Wrote {args.count} records to {args.out}")

if __name__ == '__main__':
    main()

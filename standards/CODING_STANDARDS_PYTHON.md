# SmartWin Python 编码规范

## 文档信息
- **版本**: 1.0.0
- **适用**: Python 3.11+

---

## 1. 命名规范

### 1.1 模块和包
- 小写，使用下划线分隔
- 示例: `data_processor.py`, `ai_model`

### 1.2 类名
- PascalCase
- 示例: `DataProcessor`, `AIModelTrainer`

### 1.3 函数和方法
- 小写，下划线分隔 (snake_case)
- 示例: `process_data()`, `get_model_prediction()`

### 1.4 变量
- 小写，下划线分隔
- 常量: 全大写，示例: `MAX_BATCH_SIZE = 100`
- 私有变量: 单下划线前缀，示例: `_internal_state`

### 1.5 类型提示
```python
from typing import Optional, List, Dict

def process_data(
    data: List[Dict[str, Any]],
    batch_size: int = 32,
    timeout: Optional[float] = None,
) -> List[ProcessedItem]:
```

---

## 2. 代码格式

### 2.1 PEP 8 遵从
- 使用 Black 格式化工具
- 4个空格缩进
- 最大行长度: 88字符 (Black默认)
- 函数和类之间空2行
- 类方法之间空1行

### 2.2 Import 规范
```python
# 标准库
import os
import sys
from pathlib import Path

# 第三方库
import numpy as np
import pandas as pd
from fastapi import FastAPI

# 本项目模块
from smartwin.core import config
from smartwin.models import DataAsset
```

---

## 3. 文档字符串

### 3.1 函数文档
```python
def train_model(
    training_data: pd.DataFrame,
    epochs: int = 100,
    learning_rate: float = 0.001,
) -> ModelResult:
    """训练AI治理决策模型.

    使用指定的训练数据和超参数训练模型，
    返回包含模型对象和评估指标的结果。

    Args:
        training_data: 训练数据集，包含特征和标签列
        epochs: 训练轮数，默认100
        learning_rate: 学习率，默认0.001

    Returns:
        ModelResult包含:
            - model: 训练完成的模型对象
            - metrics: 包含accuracy, f1_score的评估字典

    Raises:
        ValueError: 当training_data为空时
        ModelTrainingError: 当训练过程中发生错误时

    Example:
        >>> result = train_model(df, epochs=50)
        >>> print(f"Accuracy: {result.metrics['accuracy']:.2%}")
    """
```

---

## 4. 错误处理

### 4.1 自定义异常
```python
class SmartWinError(Exception):
    """SmartWin基础异常类."""
    pass

class DataProcessingError(SmartWinError):
    """数据处理异常."""
    def __init__(self, message: str, data_id: Optional[str] = None):
        super().__init__(message)
        self.data_id = data_id
```

### 4.2 日志记录
```python
import logging

logger = logging.getLogger(__name__)

def process_data(data: List[Dict]) -> List[ProcessedItem]:
    logger.info("Starting data processing, count=%d", len(data))
    try:
        result = _do_process(data)
        logger.info("Data processing completed, output_count=%d", len(result))
        return result
    except Exception as e:
        logger.error("Data processing failed: %s", str(e), exc_info=True)
        raise DataProcessingError(f"Processing failed: {e}") from e
```

---

## 5. 测试规范

### 5.1 测试文件命名
- 测试文件: `test_<module_name>.py`
- 测试函数: `test_<function>_<scenario>_<expected_result>`

### 5.2 pytest配置
```python
# conftest.py
import pytest

@pytest.fixture
def sample_data():
    return [{"id": 1, "name": "test"}]

@pytest.fixture
def db_session():
    # 创建测试数据库会话
    ...
```

### 5.3 测试示例
```python
def test_process_data_valid_input_returns_processed_items(sample_data):
    # Arrange
    processor = DataProcessor()

    # Act
    result = processor.process(sample_data)

    # Assert
    assert len(result) == len(sample_data)
    assert all(isinstance(item, ProcessedItem) for item in result)

def test_process_data_empty_input_raises_value_error():
    processor = DataProcessor()
    with pytest.raises(ValueError, match="Input data cannot be empty"):
        processor.process([])
```

---

*版本: 1.0.0 | 最后更新: 2026-07-27*

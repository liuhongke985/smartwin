# Helm Chart: ai-governance (PoC)

部署示例：

```bash
helm install ai-governance charts/ai-governance --set image.repository=liuhongke985/ai-governance --set image.tag=poC
```

可配置项：`values.yaml` 中的 `replicaCount`、`resources`、`service.port`、`env` 等。

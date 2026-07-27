-- SmartWin Test Data Initialization Script
-- Used for: local dev, integration tests, CI/CD environments
-- WARNING: Do NOT run in production environment!

-- ============================================================
-- Database: smartwin_data
-- ============================================================

USE smartwin_data;

-- Clear existing test data
TRUNCATE TABLE data_quality_check;
TRUNCATE TABLE data_asset;

-- Insert test data categories
INSERT INTO data_category (id, code, name, parent_id, created_by, updated_by) VALUES
(1, 'user_data', '用户数据', NULL, 'system', 'system'),
(2, 'business_data', '业务数据', NULL, 'system', 'system'),
(3, 'log_data', '日志数据', NULL, 'system', 'system'),
(4, 'user_behavior', '用户行为数据', 1, 'system', 'system'),
(5, 'user_profile', '用户画像数据', 1, 'system', 'system');

-- Insert test data assets
INSERT INTO data_asset (
    id, asset_code, asset_name, description, category_id, status,
    quality_score, storage_type, sensitivity_level, created_by, updated_by
) VALUES
(1, 'DA-001', '用户行为日志', '记录用户在平台上的所有行为事件', 4, 1,
 95.5, 'mysql', 1, 'admin', 'admin'),
(2, 'DA-002', '商品交易记录', '所有商品的购买交易记录', 2, 1,
 88.3, 'hdfs', 2, 'admin', 'admin'),
(3, 'DA-003', '用户基本信息', '用户注册信息和个人资料', 5, 1,
 99.1, 'mysql', 2, 'admin', 'admin'),
(4, 'DA-004', '系统访问日志', '系统访问和操作审计日志', 3, 1,
 92.0, 'elasticsearch', 0, 'admin', 'admin'),
(5, 'DA-005', '废弃测试数据集', '用于测试软删除功能的数据', 3, 0,
 NULL, 'mysql', 0, 'admin', 'admin');

-- Insert test quality check results
INSERT INTO data_quality_check (
    asset_id, check_type, check_status, score,
    total_records, passed_records, failed_records,
    created_by, updated_by
) VALUES
(1, 'completeness', 2, 98.5, 100000, 98500, 1500, 'system', 'system'),
(1, 'accuracy', 2, 92.3, 100000, 92300, 7700, 'system', 'system'),
(2, 'completeness', 2, 85.0, 50000, 42500, 7500, 'system', 'system'),
(3, 'consistency', 2, 99.5, 200000, 199000, 1000, 'system', 'system');

-- ============================================================
-- Database: smartwin_auth
-- ============================================================

USE smartwin_auth;

-- Test users (passwords are bcrypt hashed 'test_password_123')
INSERT INTO sys_user (
    id, username, email, display_name, status, created_by, updated_by
) VALUES
(1, 'admin', 'admin@smartwin.test', '系统管理员', 1, 'system', 'system'),
(2, 'data_manager', 'data.manager@smartwin.test', '数据管理员', 1, 'system', 'system'),
(3, 'analyst', 'analyst@smartwin.test', '数据分析师', 1, 'system', 'system'),
(4, 'viewer', 'viewer@smartwin.test', '访客用户', 1, 'system', 'system'),
(5, 'disabled_user', 'disabled@smartwin.test', '禁用用户', 0, 'system', 'system');

-- Test roles
INSERT INTO sys_role (id, code, name, description, created_by, updated_by) VALUES
(1, 'SUPER_ADMIN', '超级管理员', '拥有所有权限', 'system', 'system'),
(2, 'DATA_MANAGER', '数据管理员', '数据资产管理权限', 'system', 'system'),
(3, 'DATA_ANALYST', '数据分析师', '数据查询和分析权限', 'system', 'system'),
(4, 'VIEWER', '访客', '只读权限', 'system', 'system');

-- User role assignments
INSERT INTO sys_user_role (user_id, role_id, created_by) VALUES
(1, 1, 'system'),
(2, 2, 'system'),
(3, 3, 'system'),
(4, 4, 'system');

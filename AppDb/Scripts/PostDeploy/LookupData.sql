-- Lookup data. Edit the VALUES lists to add/change rows; MERGE keeps every DB in sync.

MERGE INTO [dbo].[Roles] AS target
USING (VALUES
    (1, N'Admin',    N'Full access'),
    (2, N'Manager',  N'Manage orders and products'),
    (3, N'Customer', N'Places orders')
) AS source ([RoleId], [RoleName], [Description])
ON target.[RoleId] = source.[RoleId]
WHEN MATCHED AND (target.[RoleName] <> source.[RoleName]
               OR ISNULL(target.[Description], N'') <> ISNULL(source.[Description], N''))
    THEN UPDATE SET [RoleName] = source.[RoleName], [Description] = source.[Description]
WHEN NOT MATCHED BY TARGET
    THEN INSERT ([RoleId], [RoleName], [Description])
         VALUES (source.[RoleId], source.[RoleName], source.[Description]);

MERGE INTO [dbo].[OrderStatuses] AS target
USING (VALUES
    (CAST(1 AS TINYINT), N'Pending'),
    (CAST(2 AS TINYINT), N'Paid'),
    (CAST(3 AS TINYINT), N'Shipped'),
    (CAST(4 AS TINYINT), N'Delivered'),
    (CAST(5 AS TINYINT), N'Cancelled')
) AS source ([OrderStatusId], [StatusName])
ON target.[OrderStatusId] = source.[OrderStatusId]
WHEN MATCHED AND target.[StatusName] <> source.[StatusName]
    THEN UPDATE SET [StatusName] = source.[StatusName]
WHEN NOT MATCHED BY TARGET
    THEN INSERT ([OrderStatusId], [StatusName])
         VALUES (source.[OrderStatusId], source.[StatusName]);

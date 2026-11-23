-- Fake data for local/dev work. Only inserts when the table is empty,
-- so it never overwrites what a developer has created by hand.

IF NOT EXISTS (SELECT 1 FROM [dbo].[Users])
BEGIN
    INSERT INTO [dbo].[Users] ([Email], [FullName], [Phone])
    VALUES (N'admin@example.com',   N'Admin User',    N'+94 70 000 0001'),
           (N'manager@example.com', N'Manager User',  N'+94 70 000 0002'),
           (N'alice@example.com',   N'Alice Perera',  NULL),
           (N'bob@example.com',     N'Bob Silva',     NULL);

    INSERT INTO [dbo].[UserRoles] ([UserId], [RoleId])
    SELECT u.[UserId], r.[RoleId]
    FROM   [dbo].[Users] AS u
           INNER JOIN [dbo].[Roles] AS r
               ON r.[RoleName] = CASE u.[Email]
                                     WHEN N'admin@example.com'   THEN N'Admin'
                                     WHEN N'manager@example.com' THEN N'Manager'
                                     ELSE N'Customer'
                                 END;
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[Products])
BEGIN
    INSERT INTO [dbo].[Products] ([Sku], [Name], [UnitPrice])
    VALUES (N'SKU-001', N'Keyboard', 4500.00),
           (N'SKU-002', N'Mouse',    1800.00),
           (N'SKU-003', N'Monitor', 52000.00);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[Orders])
BEGIN
    DECLARE @NewOrderId INT, @AliceId INT, @BobId INT;

    SELECT @AliceId = [UserId] FROM [dbo].[Users] WHERE [Email] = N'alice@example.com';
    SELECT @BobId   = [UserId] FROM [dbo].[Users] WHERE [Email] = N'bob@example.com';

    IF @AliceId IS NOT NULL
        EXEC [dbo].[usp_CreateOrder] @UserId = @AliceId, @ProductId = 1, @Quantity = 2, @OrderId = @NewOrderId OUTPUT;

    IF @BobId IS NOT NULL
        EXEC [dbo].[usp_CreateOrder] @UserId = @BobId, @ProductId = 3, @Quantity = 1, @OrderId = @NewOrderId OUTPUT;
END;

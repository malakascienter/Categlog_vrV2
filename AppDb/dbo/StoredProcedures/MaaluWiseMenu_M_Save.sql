
CREATE PROCEDURE [dbo].[MaaluWiseMenu_M_Save]
    @PropertyId   INT,
    @MenuCode     VARCHAR(10),
    @AggregatorId INT,
    @UserId       INT,
    @Outlet       VARCHAR(5)
AS
BEGIN TRY
BEGIN TRANSACTION

    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM [dbo].[AggregatorWiseMenuItem]
               WHERE MenuCode = @MenuCode AND AggregatorId = @AggregatorId
                 AND PropertyId = @PropertyId AND Outlet = @Outlet AND BrandID = 0)
    BEGIN
        RAISERROR('This Item for aggregator type is already added', 16, 1)
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[POS_OutletWiseMenuItems]
                   WHERE MenuCode = @MenuCode AND OutletCode = @Outlet AND PropertyId = @PropertyId)
    BEGIN
        RAISERROR('This Item not assign to outlet', 16, 1)
    END
    ELSE
    BEGIN
        INSERT INTO [dbo].[AggregatorWiseMenuItem]
            (MenuCode, AggregatorId, PropertyId, CreatedUserId, CreatedDateTime, Outlet, BrandID)
        VALUES
            (@MenuCode, @AggregatorId, @PropertyId, @UserId, GETDATE(), @Outlet, 0);
    END

COMMIT TRANSACTION
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    INSERT INTO GEN_ErrTable (ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage)
    VALUES (ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE())
    DECLARE @ErrorMsg VARCHAR(MAX)
    SET @ErrorMsg = ERROR_MESSAGE()
    RAISERROR(@ErrorMsg, 16, 1)
END CATCH

GO



CREATE PROCEDURE [dbo].[ComboItemBreakDown_M_Save]
    @MainMenuCode VARCHAR(4),
    @SubItem VARCHAR(4),
    @Qty INT,
    @UserId INT
AS
BEGIN TRY
    DECLARE @Remark NVARCHAR(250)

    IF EXISTS (
        SELECT 1
        FROM ComboItemBreakDown
        WHERE mainmenucode = @MainMenuCode
          AND subItemcode = @SubItem
    )
    BEGIN
        RAISERROR('Record Already Exists.', 16, 1)
    END
    ELSE
    BEGIN
        INSERT INTO ComboItemBreakDown(mainmenucode, subItemcode)
        VALUES (@MainMenuCode, @SubItem)

        DECLARE @Id BIGINT
        SELECT @Id = Id
        FROM ComboItemBreakDown
        WHERE mainmenucode = @MainMenuCode
          AND subItemcode = @SubItem

        SET @Remark = 'Combo item break down ' + @MainMenuCode + ', ' + @SubItem + ' created.'

        IF NOT EXISTS (
            SELECT 1
            FROM MenuItemWiseAlternatives
            WHERE MainMenuCode = @MainMenuCode
              AND MenuCode = @SubItem
              AND ActionButtonID = 5
        )
        BEGIN
            INSERT INTO MenuItemWiseAlternatives
                (MainMenuCode, MenuCode, AlternateMenuCode, SeqNo, AddRate, ActionButtonID, IsUpload, Qty)
            VALUES
                (@MainMenuCode, @SubItem, @SubItem, 0, 0, 5, 0, @Qty)
        END
    END
END TRY
BEGIN CATCH
    INSERT INTO GEN_ErrTable (ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage)
    VALUES (ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE())

    DECLARE @ERRmsg VARCHAR(MAX) = ERROR_MESSAGE()
    RAISERROR(@ERRmsg, 16, 1)
END CATCH

GO



CREATE PROCEDURE [dbo].[CostingSetting_M_Save]
    @Id INT,
    @CostingName VARCHAR(150),
    @Percentage DECIMAL(18,2),
    @Active BIT,
    @UserId INT,
    @PropertyId INT,
    @Operation CHAR(1)
AS
BEGIN TRY
BEGIN TRANSACTION
    SET NOCOUNT ON;
    DECLARE @Remark NVARCHAR(250)
    DECLARE @LastID INT

    IF @Operation ='I'
    BEGIN
        -- Duplicate name check on insert. This is correct and stays: the false
        -- "already exists" the audit reported was caused by the screen posting every
        -- save as an insert, which is fixed in Scienter.CostingType.js.
        IF EXISTS (SELECT 1 FROM CostingSetting where PropertyId=@PropertyId AND CostingName=@CostingName)
        BEGIN
            RAISERROR('CostingSetting Description already exists',16,1)
        END
        ELSE
        BEGIN
            INSERT INTO CostingSetting (CostingName,[Percentage],Active,PropertyId,CreatedUserId,CreatedDateTime)
            values (@CostingName,@Percentage,@Active,@PropertyId,@UserId,GETDATE())
            SET @LastID =SCOPE_IDENTITY()

            -- audit trail (legacy mechanism - already disabled by the original author)
            --SET @Remark = 'CostingSetting '+@CostingName+', '+@Percentage+' created.';
            --EXEC [dbo].[AuditTrail_InsertTableChanges] 'CostingSetting',@LastID,@UserId,'I',@Remark
            -- end of audit trail
        END
    END
    ELSE IF @Operation ='U'
    BEGIN
            -- audit trail (legacy mechanism - DISABLED, see header of this script)
            --
            -- AuditTrail_InsertToHistory raised 'Invalid audity trail log table details'
            -- because CostingSetting is not registered in AuditTrail_Tables, and the
            -- @Remark line below concatenated a DECIMAL into a varchar without CONVERT.
            -- Costing Type changes are now recorded in App_AuditLog instead.
            --
            --EXEC [dbo].[AuditTrail_InsertToHistory] 'CostingSetting',@Id
            -- end of audit trail

            UPDATE CostingSetting
            SET
            CostingName = @CostingName,
            Percentage=@Percentage,
            Active =@Active,
            PropertyId=@PropertyId,
            LastEditedUserId=@UserId,
            LastEditedDateTime=GETDATE()
            WHERE Id = @Id AND PropertyId=@PropertyId


              -- Duplicate name check on update
                IF EXISTS
                (
                    SELECT 1
                    FROM CostingSetting
                    WHERE PropertyId = @PropertyId
                      AND CostingName = @CostingName
                      AND Id <> @Id
                )
                BEGIN
                    RAISERROR('CostingSetting Description already exists',16,1)
                END
                ELSE
                BEGIN
                        UPDATE CostingSetting
                        SET
                        CostingName = @CostingName,
                        Percentage=@Percentage,
                        Active =@Active,
                        PropertyId=@PropertyId,
                        LastEditedUserId=@UserId,
                        LastEditedDateTime=GETDATE()
                        WHERE Id = @Id AND PropertyId=@PropertyId
                END

            -- audit trail (legacy mechanism - DISABLED, see above)
            --SET @Remark = 'CostingSetting '+@CostingName+', '+CONVERT(VARCHAR(50),@Percentage)+' updated.';
            --EXEC [dbo].[AuditTrail_InsertTableChanges] 'CostingSetting',@Id,@UserId,'U',@Remark
            -- end of audit trail
    END

COMMIT TRANSACTION
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
    INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

    DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
    RAISERROR(@ERRmsg,16,1)
END CATCH

GO


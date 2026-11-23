
CREATE PROCEDURE SPP_Get_Subcontractors
AS
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION
			SELECT * FROM dbo.SubContractors


            COMMIT TRANSACTION


        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRAN --RollBack in case of Error
        END CATCH 





    END

GO


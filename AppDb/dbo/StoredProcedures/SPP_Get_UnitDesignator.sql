/****** Object:  StoredProcedure [dbo].[SPP_Get_Subcontractors]    Script Date: 10/18/2018 1:03:09 PM ******/
Create PROCEDURE [dbo].[SPP_Get_UnitDesignator] 
@CompanyID INT 
AS
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION
			SELECT * FROM dbo.UnitDesignators WHERE CompanyID= @CompanyID


            COMMIT TRANSACTION


        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRAN --RollBack in case of Error
        END CATCH 





    END

GO


Create PROCEDURE [dbo].[SPP_Get_ProjectWiseSubCon]
@ProjectID INT,@BOQID INT, @SectionID INT, @WorkID INT,@SubContractorID INT,@PWSID INT
AS
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION
			SELECT * FROM dbo.ProjectWiseSubcontractors WHERE ProjectID= @ProjectID AND BOQID = @BOQID AND MainWorkID=@SectionID AND WorkID=@WorkID AND SubcontractorID=@SubContractorID


            COMMIT TRANSACTION


        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRAN --RollBack in case of Error
        END CATCH 





    END

GO


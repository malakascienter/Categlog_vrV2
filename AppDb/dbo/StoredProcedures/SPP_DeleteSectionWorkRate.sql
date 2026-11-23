--[dbo].[SPP_DeleteSectionWorkRate] 1,22,2,5,13,6,3,1
CREATE PROCEDURE [dbo].[SPP_DeleteSectionWorkRate]
    --DECLARE PARAMETERS

    @PropertyID INT,
    @ProjectID INT,
    @BOQID INT,
    @MainWorkCode INT,
    @subworkID INT,
    @RateID INT,
    @Action INT,
    @status [INT] OUTPUT
AS
DECLARE @statusIN [INT];
SET @statusIN = 0;
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;


        IF @Action = 1
        BEGIN

            DELETE FROM [dbo].[BOQMainWorkAllocations]
            WHERE id = @MainWorkCode;


        END;

        IF @Action = 2
        BEGIN
            DELETE FROM [dbo].[BOQSubWorkAllocations]
            WHERE id = @subworkID;

        END;




        IF @Action = 3
        BEGIN
		
		--select * from workdetails

		--select * from BOQRateanalysisAllocationHeaders

		--select * from BOQSubWorkAllocations

		--select * from boqrateanalysisallocationdetails


            IF (
               (
                   SELECT COUNT(*)
                   FROM workdetails
                   WHERE WorkID = @subworkID
                         AND RateAnalysisHeaderID = @RateID
               ) > 0
               )
            BEGIN

                DELETE FROM workdetails
                WHERE WorkID = @subworkID
                      AND RateAnalysisHeaderID = @RateID;

                DELETE FROM BOQRateanalysisAllocationHeaders
                WHERE WorkID = @subworkID
                      AND RateAnalysisID = @RateID
                      AND BOQID = @BOQID;



                IF (
                   (
                       SELECT COUNT(*)
                       FROM BOQSubWorkAllocations AS BSA
                           INNER JOIN workdetails AS WD
                               ON BSA.Id = WD.WorkID
                       WHERE BSA.BOQID = @BOQID
                             AND WD.RateAnalysisHeaderID = @RateID
                   ) = 0
                   )
                BEGIN

                    DELETE FROM BOQRateanalysisAllocationDetails
                    WHERE BOQID = @BOQID
                          AND RateID = @RateID;


				IF((
				select count(*) from BOQSubWorkAllocations as BSA 
				inner join workdetails as WD on BSA.Id=WD.WorkID  where WD.WorkID=@subworkID)=0)
				BEGIN
					Update BOQSubWorkAllocations set Rate=0 Where Id=@subworkID

				END

			
			
                END;
				IF((
				select count(*) from BOQSubWorkAllocations as BSA 
				inner join workdetails as WD on BSA.Id=WD.WorkID  where WD.WorkID=@subworkID)=0)
				BEGIN
					Update BOQSubWorkAllocations set Rate=0 Where Id=@subworkID

				END

				

            END;

        END;


			EXEC [dbo].[TotalRecalculateBOQ] @BOQID

        --=EXEC [dbo].[UpdateRateAllocation] @BOQID,@subworkID,@RateID
        --delete from [dbo].[BOQMainWorkAllocations] where id=@MainWorkCode




        SET @statusIN = 1;

        --ACTION 2 ENDS
        COMMIT TRAN; -- Transaction Success!
        SET @status = @statusIN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
        DECLARE @Message VARCHAR(MAX);
        SELECT @Message = ERROR_MESSAGE();
        RAISERROR(@Message, 18, 2);
        --RollBack in case of Error
        SET @status = -1;
        SELECT ERROR_NUMBER() AS ErrorNumber,
               ERROR_SEVERITY() AS ErrorSeverity,
               ERROR_STATE() AS ErrorState,
               ERROR_PROCEDURE() AS ErrorProcedure,
               ERROR_LINE() AS ErrorLine,
               ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END; --SP ENDS

GO


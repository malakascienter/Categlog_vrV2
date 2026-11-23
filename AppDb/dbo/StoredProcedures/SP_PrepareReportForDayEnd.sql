-- =============================================
-- Author:		Nivesh
-- Create date: 2025-09-22
-- Description:	Prepare Report for Day End
-- =============================================
-- SP_PrepareReportForDayEnd 1 , '2025-09-22', -999, 'CR1'

--NEW
CREATE PROCEDURE [dbo].[SP_PrepareReportForDayEnd] 
	@PropertyID INT,
	@DayEndDate DATE,
	@LocationID INT = -999,
	@ReportType CHAR(4) 
AS
BEGIN
	
	IF(@ReportType = 'CR1')
	BEGIN

    ----------------Report ProductProfitability ------------------------
    DECLARE @ReportData NVARCHAR(MAX) = '[
                                        {
                                            "Name": "Date",
                                          "Value": "'+CONVERT(VARCHAR(500),@DayEndDate)+'"
                                        },
                                          {
                                            "Name": "LocationID",
                                            "Value": "-999"
                                          },
                                          {
                                            "Name": "PropertyId",
                                            "Value": "'+CONVERT(VARCHAR(18),@PropertyID)+'"
                                          }
                                        ]'
	    INSERT INTO [dbo].[SendReportNotificationDetail]
               ([ReportType]
               ,[ReportTypeID]
               ,[ReportDate]
               ,[ReportData]
               ,[EmailSubject]
               ,[IsMailSend]
               ,[SysDate])
         VALUES
               ('CR1'
               ,1 
               ,@DayEndDate
               ,@ReportData
               ,''
               ,0
               ,GETDATE())

        -------------------------------------------------------------------------------------------

         ----------------Report Top_Consumption ------------------------
    SET @ReportData  = '[
                             {
                                "Name": "Date",
                                "Value": "'+CONVERT(VARCHAR(500),@DayEndDate)+'"
                              },
                              {
                                "Name": "LocationID",
                                "Value": "-999"
                              },
                              {
                                "Name": "PropertyID",
                                "Value": "'+CONVERT(VARCHAR(18),@PropertyID)+'"
                              }
                            ]'
	    INSERT INTO [dbo].[SendReportNotificationDetail]
               ([ReportType]
               ,[ReportTypeID]
               ,[ReportDate]
               ,[ReportData]
               ,[EmailSubject]
               ,[IsMailSend]
               ,[SysDate])
         VALUES
               ('CR1'
               ,2 
               ,@DayEndDate
               ,@ReportData
               ,''
               ,0
               ,GETDATE())

        -------------------------------------------------------------------------------------------
	END
END

GO



--SP_GetJobRequest 1

CREATE PROCEDURE [dbo].[SP_GetJobRequest]
@companyid int 

AS
	BEGIN 
		
		SELECT JH.ID ,JH.JobCardNumber, PD.ProjectName, BH.BOQName  FROM JobHeader JH INNER JOIN ProjectDetails PD ON  JH.ProjectID=PD.Id 
		INNER JOIN Customers CS ON PD.ClientID=CS.Id 
		INNER JOIN Companies CO ON CS.CompanyId=CO.CompanyID
		INNER JOIN BOQHeaders BH ON JH.BOQID=BH.Id
		WHERE CS.CompanyId=1 AND JH.Approved=0;

	END

GO


-- =============================================
-- Author:		Vinuki
-- Create date: 07.06.2024
-- Description: get pending Pos for Additional details comp.
--SP_GetPendingPOApprovalsForAddtionalDetailsComponent
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetPendingPOApprovalsForAddtionalDetailsComponent]
	

AS
BEGIN


	select distinct 
		p.id as POHeaderID,
		PoNo as PONumber ,
		c.name as CompanyName,
		l.Name as LocationName,
		p.GrossTotal,
		p.TaxTotal,
		format(p.DocumentDate,'yyyy-MM-dd') DocumentDate,
		s.Name as SupplierName ,
		p.CreatedDate,
		p.POType
	from ApprovalLogs  a
	inner join PoHeaders p on p.Id = a.TransactionHeaderID
	inner join Locations l on l.id = p.LocationID
	inner join Companies c on c.CompanyID = p.PropertyID
	inner join Suppliers s on s.ID = p.SupplierID
	where a.TransactionID = 2  and a.SeqID = 1 and a.IsComplete = 0 and c.IsPoModificationComponent = 1 and p.IsApproved = 0 
	--and p.isModificationComplete = 0
	 AND (p.isModificationComplete = 0 OR p.isModificationComplete IS NULL) -- added by vinuki 13.06.2024 
	order by p.CreatedDate desc


END

GO


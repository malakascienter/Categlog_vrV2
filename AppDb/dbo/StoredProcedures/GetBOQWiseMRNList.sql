create procedure [dbo].[GetBOQWiseMRNList] @ProjectId INT,@BOQId INT
As
BEGIN


select ID,DocNo as text from MRNRegistries where BoqID=@BOQId and ProjectID=@ProjectId


END

GO


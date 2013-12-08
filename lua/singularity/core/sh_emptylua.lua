if(SERVER)then

	local NDat=Singularity.Utl.NetMan
	
	NDat.AddDataAll({Name="Example",Val=1,Dat={{N="D",T="S",V="example"}}})
	
else

	Singularity.Utl:HookNet("Example","",function(D) print(D.D) end)
	
end		 

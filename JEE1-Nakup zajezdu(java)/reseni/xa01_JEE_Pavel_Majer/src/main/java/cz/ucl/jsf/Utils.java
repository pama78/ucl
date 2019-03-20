package cz.ucl.jsf;

import java.util.ArrayList;

public class Utils{
	@SuppressWarnings("unchecked")
	public static java.util.List asList(java.util.Collection data) {
		if(data!=null) return new ArrayList(data);
		else return new ArrayList();
	}
}

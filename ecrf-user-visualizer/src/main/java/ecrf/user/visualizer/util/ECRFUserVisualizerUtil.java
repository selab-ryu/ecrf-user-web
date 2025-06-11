package ecrf.user.visualizer.util;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;

public class ECRFUserVisualizerUtil {

	private static String[][] groupData = {
			{"BPA","bisphenols","Urine","NoE_Moc"}
			,{"BPF","bisphenols","Urine","NoE_Moc"}
			,{"BPS","bisphenols","Urine","NoE_Moc"}
			,{"MDA","oxydative","Urine","NoE_Moc"}
			,{"OHdG8","oxydative","Urine","NoE_Moc"}
			,{"OHP1","PAHs","Urine","NoE_Moc"}
			,{"NAP2","PAHs","Urine","NoE_Moc"}
			,{"PHE1","PAHs","Urine","NoE_Moc"}
			,{"FLU2","PAHs","Urine","NoE_Moc"}
			,{"MP","parabens","Urine","NoE_Moc"}
			,{"EP","parabens","Urine","NoE_Moc"}
			,{"PP","parabens","Urine","NoE_Moc"}
			,{"BP","parabens","Urine","NoE_Moc"}
			,{"PCS","phenols","Urine","NoE_Moc"}
			,{"BP3","phenols","Urine","NoE_Moc"}
			,{"PBA3","phenols","Urine","NoE_Moc"}
			,{"MNBP","phthalates","Urine","NoE_Moc"}
			,{"MEP","phthalates","Urine","NoE_Moc"}
			,{"MCPP","phthalates","Urine","NoE_Moc"}
			,{"MEP","phthalates","Urine","NoE_Moc"}
			,{"MCPP","phthalates","Urine","NoE_Moc"}
			,{"MBZP","phthalates","Urine","NoE_Moc"}
			,{"MMP","phthalates","Urine","NoE_Moc"}
			,{"MEOHP","phthalates","Urine","NoE_Moc"}
			,{"MEHHP","phthalates","Urine","NoE_Moc"}
			,{"MECCP","phthalates","Urine","NoE_Moc"}
			,{"MIBP","phthalates","Urine","NoE_Moc"}
			,{"t_t_MA","VOCs","Urine","NoE_Moc"}
			,{"BMA","VOCs","Urine","NoE_Moc"}
			,{"MBZP_BM","phthalates","breast milk","NoE_Moc"}
			,{"MEHA","phthalates","breast milk","NoE_Moc"}
			,{"MEHP","phthalates","breast milk","NoE_Moc"}
			,{"MNOP","phthalates","breast milk","NoE_Moc"}
			,{"MINP","phthalates","breast milk","NoE_Moc"}
			,{"MEHTP","phthalates","breast milk","NoE_Moc"}
			,{"MIDP","phthalates","breast milk","NoE_Moc"}
			,{"Pb","heavy metals","breast milk","NoE_Moc"}
			,{"Cd","heavy metals","breast milk","NoE_Moc"}
			,{"Hg","heavy metals","breast milk","NoE_Moc"}
			,{"As","heavy metals","breast milk","NoE_Moc"}
			,{"PFDeA","PHAS","breast milk","NoE_Moc"}
			,{"PFHxS","PHAS","breast milk","NoE_Moc"}
			,{"PFNA","PHAS","breast milk","NoE_Moc"}
			,{"PFOA","PHAS","breast milk","NoE_Moc"}
			,{"PFOS","PHAS","breast milk","NoE_Moc"}
			,{"MMP","phthalates","breast milk","KATRI"}
			,{"MEP","phthalates","breast milk","KATRI"}
			,{"MBZP","phthalates","breast milk","KATRI"}
			,{"MIBP","phthalates","breast milk","KATRI"}
			,{"MEHA","phthalates","breast milk","KATRI"}
			,{"MEHP","phthalates","breast milk","KATRI"}
			,{"MNOP","phthalates","breast milk","KATRI"}
			,{"MINP","phthalates","breast milk","KATRI"}
			,{"MEHTP","phthalates","breast milk","KATRI"}
			,{"MIDP","phthalates","breast milk","KATRI"}
			,{"MIDP","phthalates","breast milk","KATRI"}
			,{"Pb","heavy metals","breast milk","KATRI"}
			,{"Cd","heavy metals","breast milk","KATRI"}
			,{"Hg","heavy metals","breast milk","KATRI"}
			,{"As","heavy metals","breast milk","KATRI"}
			,{"MFDeA","PFAS","breast milk","KATRI"}
			,{"PFHxS","PFAS","breast milk","KATRI"}
			,{"PFNA","PFAS","breast milk","KATRI"}
			,{"PFOA","PFAS","breast milk","KATRI"}
			,{"PFOS","PFAS","breast milk","KATRI"}
			,{"BPA","bisphenols","Urine","EDPS"}
			,{"BPF","bisphenols","Urine","EDPS"}
			,{"BPS","bisphenols","Urine","EDPS"}
			,{"TCS","phenols","Urine","EDPS"}
			,{"BP3","phenols","Urine","EDPS"}
			,{"MP","parabens","Urine","EDPS"}
			,{"EP","parabens","Urine","EDPS"}
			,{"PP","parabens","Urine","EDPS"}
			,{"BP","parabens","Urine","EDPS"}
			,{"OHP1","PAHs","Urine","EDPS"}
			,{"NAP2","PAHs","Urine","EDPS"}
			,{"PHE1","PAHs","Urine","EDPS"}
			,{"FLU2","PAHs","Urine","EDPS"}
			,{"t_t_MA","VOCs","Urine","EDPS"}
			,{"BMA","VOCs","Urine","EDPS"}
			,{"COT","VOCs","Urine","EDPS"}
			,{"PBA3","phenols","Urine","EDPS"}
			,{"MNBP","phthalates","Urine","EDPS"}
			,{"MEP","phthalates","Urine","EDPS"}
			,{"MCPP","phthalates","Urine","EDPS"}
			,{"MBZP","phthalates","Urine","EDPS"}
			,{"MMP","phthalates","Urine","EDPS"}
			,{"MEOHP","phthalates","Urine","EDPS"}
			,{"MEHHP","phthalates","Urine","EDPS"}
			,{"MECPP","phthalates","Urine","EDPS"}
			,{"MIBP","phthalates","Urine","EDPS"}
			,{"MDA","oxydative stress","Urine","EDPS"}
			,{"OHdG8","oxydative stress","Urine","EDPS"}
			,{"BPA_baby","bisphenols","Urine Baby","EDPS"}
			,{"BPF_baby","bisphenols","Urine Baby","EDPS"}
			,{"BPS_baby","bisphenols","Urine Baby","EDPS"}
			,{"TCS_baby","phenols","Urine Baby","EDPS"}
			,{"BP3_baby","phenols","Urine Baby","EDPS"}
			,{"MP_baby","parabens","Urine Baby","EDPS"}
			,{"EP_baby","parabens","Urine Baby","EDPS"}
			,{"PP_baby","parabens","Urine Baby","EDPS"}
			,{"BP_baby","parabens","Urine Baby","EDPS"}
			,{"MNBP_baby","phthalates","Urine Baby","EDPS"}
			,{"MEP_baby","phthalates","Urine Baby","EDPS"}
			,{"MCPP_baby","phthalates","Urine Baby","EDPS"}
			,{"MBZP_baby","phthalates","Urine Baby","EDPS"}
			,{"MCOP_baby","phthalates","Urine Baby","EDPS"}
			,{"MMP_baby","phthalates","Urine Baby","EDPS"}
			,{"MEOHP_baby","phthalates","Urine Baby","EDPS"}
			,{"MEHHP_baby","phthalates","Urine Baby","EDPS"}
			,{"MECPP_baby","phthalates","Urine Baby","EDPS"}
			,{"MEHP_baby","phthalates","Urine Baby","EDPS"}
			,{"MIBP_baby","phthalates","Urine Baby","EDPS"}
			,{"MINP_baby","phthalates","Urine Baby","EDPS"}
	};
	
	public static JSONArray getVisualGroup(String GroupName) {
		JSONArray array = JSONFactoryUtil.createJSONArray();
		
		_log.info("GroupName : "+GroupName);

		for(int i=0; i<groupData.length ; i++ ) {			
			JSONObject obj = JSONFactoryUtil.createJSONObject();
				
			if( GroupName == groupData[i][3]) {
				
					obj.put("termName", groupData[i][0]);
					obj.put("g1", groupData[i][1]);
					obj.put("g2", groupData[i][2]);
					obj.put("cohot", groupData[i][3]);
				
					_log.info(obj.toJSONString());
					if( obj != null)
					array.put(obj);
			}
			
		}

		return array;
	}
	
	private static Log _log = LogFactoryUtil.getLog(ECRFUserVisualizerUtil.class);
}

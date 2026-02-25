package ecrf.user.crf.util.data;

import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;

import java.text.SimpleDateFormat;
import java.util.List;

import teeth.model.TreatmentHistory;

public class TeethUtil {
	public static String convertJSONString(List<TreatmentHistory> historyList) {
		String result = null;
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		try {
			List<TreatmentHistory> list = historyList;
	        JSONObject grid = JSONFactoryUtil.createJSONObject();
	        _log.info("-----grid");
	        
	        for (int i=0; i<list.size(); i++) {
	        	TreatmentHistory th = list.get(i);
	            JSONObject entry = JSONFactoryUtil.createJSONObject();

	            entry.put("tt_teethNum", th.getTeethNum());
	            
	            if(th.getState() != null) {
	            	entry.put("tt_teethState", th.getState());
	            } else {
	            	entry.put("tt_teethState", "");
	            }
	            
	            if(th.getTreatment() != null) {
	            	entry.put("tt_teethTreatment", th.getTreatment());
	            } else {
	            	entry.put("tt_teethTreatment", "");
	            }
	            
	            entry.put("tt_visitDate", sdf.format(th.getTreatmentDate()));
	            //entry.put("tt_createDate", th.getCreateDate().getTime());
	            
	            //entry.put("tt_modifiedDate", th.getModifiedDate().getTime());

	            // row index as key
	            grid.put(String.valueOf(i+1),entry);
	        }
	        
	        // 4. 최종 JSON 문자열로 변환
	        result = grid.toJSONString();
		} catch(Exception e) {
			e.printStackTrace();
			return null;
		}
		
		return result;
	}
	
	private static Log _log = LogFactoryUtil.getLog(TeethUtil.class);
}

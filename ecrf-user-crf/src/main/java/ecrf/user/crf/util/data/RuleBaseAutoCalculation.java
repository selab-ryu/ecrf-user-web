package ecrf.user.crf.util.data;

import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.util.Validator;

import java.util.Date;

import ecrf.user.model.Subject;

public class RuleBaseAutoCalculation {
	private Log _log;

	public RuleBaseAutoCalculation() {
		_log = LogFactoryUtil.getLog(this.getClass().getName());
	}
	
	public JSONObject ruleBaseAutoCalculate(JSONObject answer, Subject subject) {
		System.out.println("calculation started + : " + answer.toJSONString());
		if(answer.has("conciousness")) {
			//A=15 D=12 DD=10 S=8 SC=5 C=3
			switch(answer.getInt("conciousness")) {
				case 0:
					answer.put("gcs", 15);
					break;
				case 1:
					answer.put("gcs", 12);
					break;
				case 2:
					answer.put("gcs", 10);
					break;
				case 3:
					answer.put("gcs", 8);
					break;
				case 4:
					answer.put("gcs", 5);
					break;
				case 5:
					answer.put("gcs", 3);
					break;
				default:
					break;
			}
		}
		
		//COGas scoring
		int cogasScore = 0;
		Date now = new Date();
		Date subjectBirth = subject.getBirth();
		int subjectAge = now.getYear() - subjectBirth.getYear();
		
		if(subjectAge > 50) {
			cogasScore++;
		}
		
		if(answer.has("gcs")) {
			if(answer.getInt("gcs") < 12) {
				cogasScore++;
			}
		}
		
		if(answer.has("shock")) {
			if(Validator.isNotNull(answer.getJSONArray("shock")) && answer.getJSONArray("shock").getInt(0) == 1) {
				cogasScore++;
			}
		}
		
		if(answer.has("hbotTrial")) {
			if(Validator.isNotNull(answer.getJSONArray("hbotTrial")) && answer.getJSONArray("hbotTrial").getInt(0) == 0) {
				cogasScore++;
			}
		}
		
		if(answer.has("ck_0")) {
			if(answer.getInt("ck_0") > 320) {
				cogasScore++;
			}
		}
		if(cogasScore > 0 && cogasScore < 6) {
			answer.put("cogas_score", cogasScore);
		}
		
		//stay days
		Date visitDate = new Date(answer.getLong("visit_date"));
		Date outDate = null;
		if(answer.has("out_hp_date")) {
			outDate = new Date(answer.getLong("out_hp_date"));
		}
		
		long stayDays = 0;
		if(Validator.isNotNull(outDate)) {
			stayDays = outDate.getTime() - visitDate.getTime();
			answer.put("total_hp_date", stayDays);
		}
		
		//ALP/ ALT
		if(answer.has("alt_0") && answer.has("alp_0")) {
			double divValue = answer.getInt("alt_0") / answer.getInt("alp_0");
			answer.put("alt_alp_0", divValue);
		}
		if(answer.has("alt_1") && answer.has("alp_1")) {
			double divValue = answer.getInt("alt_1") / answer.getInt("alp_1");
			answer.put("alt_alp_1", divValue);
		}
		if(answer.has("alt_2") && answer.has("alp_2")) {
			double divValue = answer.getInt("alt_2") / answer.getInt("alp_2");
			answer.put("alt_alp_2", divValue);
		}
		
		//hbot
		if(answer.has("first_hbot_time")) {
			Date hbotTime = new Date(answer.getLong("first_hbot_time"));
			if(answer.has("detect_time")) {
				Date detectTime = new Date(answer.getLong("detect_Time"));
				long hour = (hbotTime.getTime() - detectTime.getTime()) / 3600000;
				answer.put("detect_to_1st_hbot", hour);
			}
			if(answer.has("hp_arrived")) {
				Date arrivedTime = new Date(answer.getLong("hp_arrived"));
				long hour = (hbotTime.getTime() - arrivedTime.getTime()) / 3600000;
				answer.put("arrive_to_1st_hbot", hour);
			}
		}
		if(answer.has("second_hbot_time")) {
			Date hbotTime = new Date(answer.getLong("second_hbot_time"));
			if(answer.has("hp_arrived")) {
				Date arrivedTime = new Date(answer.getLong("hp_arrived"));
				long hour = (hbotTime.getTime() - arrivedTime.getTime()) / 3600000;
				answer.put("arrive_to_2nd_hbot", hour);
			}
		}
		
		if(answer.has("hp_hbot_num") && answer.has("out_hbot_num")) {
			answer.put("total_hbot", answer.getInt("hp_hbot_num") + answer.getInt("out_hbot_num"));
		}
		
		//total test
		if(answer.has("lymphocyte_0")) {
			if(answer.has("neutropil_0")) {
				double divValue = answer.getDouble("neutropil_0") / answer.getDouble("lymphocyte_0");
				answer.put("nrl_0", divValue);
			}
			if(answer.has("monocyte_0")) {
				double divValue = answer.getDouble("monocyte_0") / answer.getDouble("lymphocyte_0");
				answer.put("mlr_0", divValue);
			}
			if(answer.has("plt_0")) {
				double divValue = answer.getDouble("plt_0") / answer.getDouble("lymphocyte_0");
				answer.put("plr_0", divValue);
			}
			
		}
		return answer;
	}
	
}

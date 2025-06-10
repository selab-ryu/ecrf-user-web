/**
 * 
 */
package ecrf.user.visualizer.command.resource;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCResourceCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCResourceCommand;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;
import com.sx.icecap.service.DataTypeLocalService;

import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.attribute.ECRFUserCRFAttributes;
import ecrf.user.model.CRF;
import ecrf.user.model.LinkCRF;
import ecrf.user.service.CRFLocalService;
import ecrf.user.service.LinkCRFLocalService;
import ecrf.user.visualizer.constants.ECRFVisualizerMVCCommand;
import ecrf.user.visualizer.constants.ECRFVisualizerPortletKeys;

/**
 * @author dev-ryu
 *
 */

@Component(
    immediate = true,
    property = {
    		"javax.portlet.name=" + ECRFVisualizerPortletKeys.ECRFVISUALIZER,
            "mvc.command.name="+ECRFVisualizerMVCCommand.RESOURCE_GET_NOE_MOC
    },
    service = MVCResourceCommand.class
)

public class GetNoeMocDataResourceCommand extends BaseMVCResourceCommand {

	@Override
	protected void doServeResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
			throws Exception {
		
		long crfId = ParamUtil.getLong(resourceRequest, ECRFUserCRFAttributes.CRF_ID); // CRF Id를 파라미터로 받아옴
		ThemeDisplay themeDisplay = (ThemeDisplay)resourceRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		// get CRF
		CRF crf = _crfLocalService.getCRF(crfId); // CRF Id를 통해 CRF를 가져옴
		//_log.info("crf id : " + String.valueOf(crfId));
		
		JSONObject dataObj = JSONFactoryUtil.createJSONObject(); //빈 data Obj 생성
		
		// get datatype structure and set to form JSON Object
		String formStr = _dataTypeLocalService.getDataTypeStructure(crf.getDatatypeId()); // CRF의 datatype structure 구조를 가져옴
		JSONObject formObj = null; // 빈 formObj 생성
		try {
			formObj = JSONFactoryUtil.createJSONObject(formStr); // formObj에 DataType Structure 구조를 입력
		} catch (Exception e) {
			e.printStackTrace();
		}
		dataObj.put("form", formObj); // dataObj에 formObj를 form이라는 필드 이름으로 입력
		
		// get crf's all data
		List<LinkCRF> linkList = _linkCRFLocalService.getLinkCRFByG_C(themeDisplay.getScopeGroupId(), crfId); // CRF Id를 통해 해당 CRF의 모든 데이터를 가져옴 -> LinkCRF에 SubjectID, CRFID, StructuredDataID 다 외래키로 들어있음
		//_log.info("link list size : " + linkList.size());
		
		// trimester count {total, 1st, 2nd, 3rd, 4th}
		Integer[] trimesterCount = {0,0,0,0,0}; // 각 trimester마다 개수를 셀 Count Array를 생성
				
		JSONArray sdArr = JSONFactoryUtil.createJSONArray(); // CRFID가 맞는 모든 sdObj를 담는 Array
		
		// search data, and aggregate by triemster
		for(LinkCRF link : linkList) { // 각 CRF Data마다
			long sdId = link.getStructuredDataId(); // StructureDataId 조회 -> CRF 응답 데이터 들어있는 Data의 Id
			
			// get Structured Data and check trimester
			if(Validator.isNotNull(sdId)) { // StructureDataId가 유효하면
				String sdStr = _dataTypeLocalService.getStructuredData(sdId); // 해당 ID의 StructureData를 가져옴
				
				JSONObject sdObj = null; // 빈 sdObj 생성
				
				// create json object
				try {
					sdObj = JSONFactoryUtil.createJSONObject(sdStr); // sdObj에 StructureData로 JSON을 입력
				} catch (Exception e) {
					e.printStackTrace();
				}
				
				// add sd obj to sd arr
				if(Validator.isNotNull(sdObj)) { // sdObj가 유효하면
					sdArr.put(sdObj); // sdArray에 sdObj 추가
					trimesterCount[0]++;	// valid data count -> total에 ++

					// aggregate trimester count
					if(sdObj.has("trimester")) { // sdObj에 trimester 정보가 있으면
						JSONArray trimester = sdObj.getJSONArray("trimester"); // 해당 정보를 읽어옴
						String trimesterValStr = trimester.getString(0);
						int trimesterVal = Integer.valueOf(trimesterValStr); // 여기까지 읽어옴
						
						trimesterCount[trimesterVal]++; // 해당 trimester에 ++
					}
				}
			}
		}
		/* log count
		for(Integer count : trimesterCount) {
			_log.info(count);
		}
		*/
		
		// add count to data obj
		JSONArray countArr = null; // 빈 CountArray 생성
		try {
			countArr = JSONFactoryUtil.createJSONArray(trimesterCount); // countArray에 trimesterCount JSONArray로 만들어서 저장
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		// add count arr and sd arr to data obj
		dataObj.put("count", countArr); // dataObj에 CountArray를 count라는 필드 이름으로 입력
		//dataObj.put("data", sdArr); // dataObj에 sdArray를 data라는 필드 이름으로 입력 -> 대체됨
		
		JSONArray avgArr = JSONFactoryUtil.createJSONArray();
		avgArr = setNoEMoCData(sdArr);
		dataObj.put("data", avgArr); // 변경된 Arr Data
		
		//여기에 전처리부 제작
		
		
		// write data obj to response
		PrintWriter pw = resourceResponse.getWriter(); // HTTP로 전송 준비
		pw.write(dataObj.toString()); // dataObj를 String 형태로 HTTP 버퍼에 입력
		pw.flush(); // 버퍼 사출
		pw.close(); // 버퍼 종료
	}
	
	private JSONArray setNoEMoCData(JSONArray sdArr)
	{
		JSONArray dataArray = sdArr;
		String[] termNames = { "BPA", "BPF", "BPS", "TCS", "BP3", "MP", "EP", "PP", "BP" };
		Map<String, double[]> trimesterSums = new HashMap<>();
		Map<String, int[]> trimesterCounts = new HashMap<>();
		
	    for (int i = 0; i < sdArr.length(); i++) {
	        
	    	
	    	//조건에 맞지 않거나, null값인 경우 제외
	        JSONObject item = sdArr.getJSONObject(i);
	        if (item == null) {
	            continue;
	        }

	        JSONArray triArr = item.getJSONArray("trimester");
	        if (triArr == null || triArr.length() == 0) {
	            continue;
	        }
	        
	        String trimester = triArr.getString(0);
	        if (trimester == null || trimester.isEmpty()) {
	            continue;
	        }

	        int idx;
	        try {
	            idx = Integer.parseInt(trimester) - 1; // "1" → 0, "2" → 1, "3" → 2
	            if (idx < 0 || idx > 2) {
	                continue;
	            }
	        } catch (NumberFormatException e) {
	            continue;
	        }

	        
	        for (String term : termNames) {
	            if (!item.has(term)) {
	                continue;
	            }
	            Object valObj = item.opt(term);
	            if (!(valObj instanceof Number)) {
	                continue;
	            }
	            double value = ((Number) valObj).doubleValue();

	            // 합계 초기화
	            trimesterSums.computeIfAbsent(term, k -> new double[3]);
	            // 카운트 초기화
	            trimesterCounts.computeIfAbsent(term, k -> new int[3]);

	            trimesterSums.get(term)[idx] += value;
	            trimesterCounts.get(term)[idx]++;
	        }
	    }

	    // 디버그 출력용
	    System.out.println("=== Count by Term and Trimester ===");
	    for (Map.Entry<String, int[]> entry : trimesterCounts.entrySet()) {
	        String term = entry.getKey();
	        int[] cnts = entry.getValue();
	        System.out.printf("%s → t1: %d, t2: %d, t3: %d%n", term, cnts[0], cnts[1], cnts[2]);
	    }

	    // 최종 결과 JSONArray 생성: termName 별 평균 계산 후 JSONObject로 담음
	    JSONArray resultArr = JSONFactoryUtil.createJSONArray();
	    int idCounter = 1;
	    for (String term : trimesterSums.keySet()) {
	        double[] sums = trimesterSums.get(term);
	        int[] cnts = trimesterCounts.getOrDefault(term, new int[3]);

	        double avg1 = (cnts[0] > 0) ? (sums[0] / cnts[0]) : 0.0;
	        double avg2 = (cnts[1] > 0) ? (sums[1] / cnts[1]) : 0.0;
	        double avg3 = (cnts[2] > 0) ? (sums[2] / cnts[2]) : 0.0;

	        JSONObject row = JSONFactoryUtil.createJSONObject();
	        row.put("id", idCounter++);
	        row.put("termName", term);
	        row.put("t1", avg1);
	        row.put("t2", avg2);
	        row.put("t3", avg3);

	        resultArr.put(row);
	    }

	    // 디버그 출력용
	    System.out.println("=== Result JSONArray ===");
	    for (int i = 0; i < resultArr.length(); i++) {
	        System.out.println(resultArr.getJSONObject(i).toString());
	    }

	    return resultArr;

	}
	
	private Log _log = LogFactoryUtil.getLog(GetNoeMocDataResourceCommand.class);
	
	@Reference
	private LinkCRFLocalService _linkCRFLocalService;

	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;	
}

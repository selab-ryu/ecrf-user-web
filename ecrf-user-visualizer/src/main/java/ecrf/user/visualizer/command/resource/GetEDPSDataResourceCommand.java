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
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

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
            "mvc.command.name="+ECRFVisualizerMVCCommand.RESOURCE_GET_EDPS
    },
    service = MVCResourceCommand.class
)

public class GetEDPSDataResourceCommand extends BaseMVCResourceCommand {//아직 완성 x

	@Override
	protected void doServeResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
			throws Exception {
		
		long crfId = ParamUtil.getLong(resourceRequest, ECRFUserCRFAttributes.CRF_ID);
		ThemeDisplay themeDisplay = (ThemeDisplay)resourceRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		// get CRF
		CRF crf = _crfLocalService.getCRF(crfId);
		_log.info("crf id : " + String.valueOf(crfId));
		
		JSONObject dataObj = JSONFactoryUtil.createJSONObject();
		
		// get datatype structure and set to form JSON Object
		String formStr = _dataTypeLocalService.getDataTypeStructure(crf.getDatatypeId());
		JSONObject formObj = null;
		try {
			formObj = JSONFactoryUtil.createJSONObject(formStr);
		} catch (Exception e) {
			e.printStackTrace();
		}
		dataObj.put("form", formObj);
		
		// get crf's all data
		List<LinkCRF> linkList = _linkCRFLocalService.getLinkCRFByG_C(themeDisplay.getScopeGroupId(), crfId);
		_log.info("link list size : " + linkList.size());
		
		JSONArray sdArr = JSONFactoryUtil.createJSONArray();
		
		// search data, and aggregate by triemster
		for(LinkCRF link : linkList) {
			long sdId = link.getStructuredDataId();
			
			// get Structured Data and check trimester
			if(Validator.isNotNull(sdId)) {
				String sdStr = _dataTypeLocalService.getStructuredData(sdId);
				
				JSONObject sdObj = null;
				
				// create json object
				try {
					sdObj = JSONFactoryUtil.createJSONObject(sdStr);
				} catch (Exception e) {
					e.printStackTrace();
				}
				
				// add sd obj to sd arr
				if(Validator.isNotNull(sdObj)) {
					sdArr.put(sdObj);
				}
			}
		}
				
		// add count arr and sd arr to data obj
		dataObj.put("data", sdArr);
		
		// write data obj to response
		PrintWriter pw = resourceResponse.getWriter();
		pw.write(dataObj.toString());
		pw.flush();
		pw.close();
	}
	
	
	   private JSONArray preprocessEDPSData(JSONArray sdArr)
	   {
	      JSONArray dataArray = sdArr;
	      String[] termNames = { "BPA", "EP", "MBZP", "MECPP" };
	      Map<String, Map<String, Double>> trimesterSums = new HashMap<>();
	      Map<String, Map<String, Integer>> trimesterCounts = new HashMap<>();
	      Set<String> trimesterSet = new HashSet<>();
	      
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

	           
	           trimesterSet.add(trimester);

	           for (String term : termNames) {
	               if (!item.has(term)) continue;
	               Object valObj = item.opt(term);
	               if (!(valObj instanceof Number)) continue;

	               double value = ((Number) valObj).doubleValue();

	               trimesterSums.computeIfAbsent(term, k -> new HashMap<>());
	               trimesterCounts.computeIfAbsent(term, k -> new HashMap<>());

	               Map<String, Double> sumMap = trimesterSums.get(term);
	               Map<String, Integer> countMap = trimesterCounts.get(term);

	               sumMap.put(trimester, sumMap.getOrDefault(trimester, 0.0) + value);
	               countMap.put(trimester, countMap.getOrDefault(trimester, 0) + 1);
	           }
	       }

	       // 디버그 출력용
	       System.out.println("=== Count by Term and Trimester ===");
	       for (Map.Entry<String, Map<String, Integer>> entry : trimesterCounts.entrySet()) {
	    	    String term = entry.getKey();
	    	    Map<String, Integer> countsMap = entry.getValue();

	    	    System.out.printf("%s → ", term);
	    	    // trimester 키가 동적으로 변하니, keys를 정렬해서 출력하거나, 그냥 출력
	    	    // 예: t1, t2, t3 ... 또는 모든 trimester key 출력
	    	    for (String trimester : countsMap.keySet()) {
	    	        System.out.printf("t%s: %d, ", trimester, countsMap.get(trimester));
	    	    }
	    	    System.out.println();
	    	}


	       // 최종 결과 JSONArray 생성: termName 별 평균 계산 후 JSONObject로 담음
	       JSONArray resultArr = JSONFactoryUtil.createJSONArray();
	       int idCounter = 1;
	       List<String> sortedTrimesters = trimesterSet.stream().sorted().collect(Collectors.toList());

	       for (String term : termNames) {
	           if (!trimesterSums.containsKey(term)) continue;

	           JSONObject row = JSONFactoryUtil.createJSONObject();
	           row.put("id", idCounter++);
	           row.put("termName", term);

	           Map<String, Double> sumMap = trimesterSums.get(term);
	           Map<String, Integer> countMap = trimesterCounts.getOrDefault(term, new HashMap<>());

	           for (String tri : sortedTrimesters) {
	               double sum = sumMap.getOrDefault(tri, 0.0);
	               int count = countMap.getOrDefault(tri, 0);
	               double avg = (count > 0) ? sum / count : 0.0;
	               row.put("t" + tri, avg);
	           }

	           resultArr.put(row);
	       }


	       // 디버그 출력용
	       System.out.println("=== Result JSONArray ===");
	       for (int i = 0; i < resultArr.length(); i++) {
	           System.out.println(resultArr.getJSONObject(i).toString());
	       }

	       return resultArr;

	   }
	
	private Log _log = LogFactoryUtil.getLog(GetEDPSDataResourceCommand.class);
	
	@Reference
	private LinkCRFLocalService _linkCRFLocalService;

	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;	
}

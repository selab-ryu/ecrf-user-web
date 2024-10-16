package ecrf.user.crf.command.render.data.dialog;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Validator;
import com.sx.icecap.model.StructuredData;
import com.sx.icecap.service.DataTypeLocalService;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.apache.commons.math3.distribution.RealDistribution;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.service.CRFLocalService;

import org.apache.commons.math3.distribution.NormalDistribution;
import org.apache.commons.math3.distribution.RealDistribution;
import org.apache.commons.math3.stat.descriptive.SummaryStatistics;
import org.apache.commons.math3.stat.descriptive.moment.Mean;
import org.apache.commons.math3.stat.inference.KolmogorovSmirnovTest;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF,
	        "mvc.command.name=" + ECRFUserMVCCommand.RENDER_DIALOG_CRF_DATA_GRAPH,
	    },
	    service = MVCRenderCommand.class
	)
public class DialogGraphRenderCommand implements MVCRenderCommand{
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException{
		_log.info("Render Graph popup");
		
		String termName = ParamUtil.getString(renderRequest, "termName");
		_log.info(termName);
		
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.CRF_ID);
		long dataTypeId = _crfLocalService.getDataTypeId(crfId);
		
		List<StructuredData> sd = _dataTypeLocalService.getStructuredDatas(dataTypeId);
		String crfForm = "";
		JSONArray crfFormArr = null;
		
		try {
			crfForm = _dataTypeLocalService.getDataTypeStructure(dataTypeId);
			crfFormArr = JSONFactoryUtil.createJSONArray(JSONFactoryUtil.createJSONObject(crfForm).getString("terms"));
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		JSONObject compObj = JSONFactoryUtil.createJSONObject();
		for(int i = 0; i < crfFormArr.length(); i++) {
			if(crfFormArr.getJSONObject(i).getString("termName").equals(termName)) {
				compObj = crfFormArr.getJSONObject(i);
			}
		}
		
		
		
		if(compObj.getString("termType").equals("List")) {
			_log.info(termName);
			JSONArray options = compObj.getJSONArray("options");
			String[] datas = new String[options.length()];
			String[] values = new String[options.length()];
			int[] valueCounts = new int[options.length()];
			
			for (int j = 0; j < options.length(); j++) {
				datas[j] = options.getJSONObject(j).getJSONObject("label").getString("en_US");
				values[j] = options.getJSONObject(j).getString("value");
				valueCounts[j] = 0;
			}
			
			
			for (int k = 0; k < sd.size(); k++) {
				String answers = sd.get(k).getStructuredData();
				JSONObject ansObj = null;
				
				try {
					ansObj = JSONFactoryUtil.createJSONObject(answers);
				} catch (Exception e) {
					e.printStackTrace();
				}
				
				if (ansObj.has(termName)) {
					for (int l = 0; l < values.length; l++) {
						if (Validator.isNotNull(ansObj.getJSONArray(termName))) {
							for (int m = 0; m < ansObj.getJSONArray(termName).length(); m++) {
								if (values[l].equals(ansObj.getJSONArray(termName).getString(m))) {
									valueCounts[l]++;
								}
							}
						}
					}
				} else {

				}
			}
			renderRequest.setAttribute("type", compObj.getString("termType"));
			renderRequest.setAttribute("datas", datas);
			renderRequest.setAttribute("values", valueCounts);

			return ECRFUserJspPaths.JSP_DIALOG_CRF_DATA_GRAPH;
		}else if (compObj.getString("termType").equals("Numeric")) {
			List<String> datas = new ArrayList<>();

			for (int i = 0; i < sd.size(); i++) {
				JSONObject ansObj = null;

				try {
					ansObj = JSONFactoryUtil.createJSONObject(sd.get(i).getStructuredData());
				} catch (Exception e) {
					e.printStackTrace();
				}

				if (!ansObj.getString(termName).isEmpty()) {
					datas.add(ansObj.getString(termName));
				}

			}

			List<Double> listDouble = new ArrayList<>();
			for(String i : datas) {
				listDouble.add(Double.parseDouble(i));
			}
			
			renderRequest.setAttribute("datas", datas.toArray(new String[datas.size()]));
			/*
			 * _log.info("gg: " + datas.size()); if(datas.size() == 0) {
			 * renderRequest.setAttribute("type", "empty"); return
			 * ECRFUserJspPaths.JSP_DIALOG_CRF_DATA_GRAPH; }
			 */

			// List where you want to insert the default statistics entry
			List<String> statistics_name = new ArrayList<>();
			List<String> statistics_value = new ArrayList<>();
			
			statistics_name.add("Average");
			statistics_name.add("Variance");
			statistics_name.add("Standard_Deviation");
			
			// Calculate the average
			double sum = 0;

			for (double i : listDouble) {
				sum += i;
			}
			
			double graph_avg = (double) sum / listDouble.size();
			
			statistics_value.add(String.format("%.2f", graph_avg));
			
			// Calculate the variance
			sum = 0;

			for (double i : listDouble) {
				sum += Math.pow(i - graph_avg, 2);
			}

			double graph_var = (double) sum / listDouble.size();

			statistics_value.add(String.format("%.2f", graph_var));
			
			// Calculate the standard deviation
			double graph_sd = Math.sqrt(graph_var);
			
			statistics_value.add(String.format("%.2f", graph_sd));

			// List to insert a quartile entry
			List<String> quartiles_name = new ArrayList<>();
			List<String> quartiles_value = new ArrayList<>();
			
			quartiles_name.add("IQR_1");
			quartiles_name.add("Median");
			quartiles_name.add("IQR_3");
			
			// Calculate the quartile
			double graph_iqr_1 = exportPercentile(listDouble, 0.25);
			quartiles_value.add(String.format("%.2f", graph_iqr_1));
			
			double graph_median = exportPercentile(listDouble, 0.5);
			quartiles_value.add(String.format("%.2f", graph_median));
			
			double graph_iqr_3 = exportPercentile(listDouble, 0.75);
			quartiles_value.add(String.format("%.2f", graph_iqr_3));
			
			// List to insert normality test values
			List<String> normality_name = new ArrayList<>();
			List<String> normality_value = new ArrayList<>();
			
			normality_name.add("ShapiroWilk");

			Double[] objectArray = { 80.0, 70.0, 70.0, 78.0, 97.0, 137.0, 72.0, 68.0, 74.0, 110.0, 105.0, 72.0, 93.0, 72.0, 64.0, 78.0, 67.0, 114.0, 68.0, 72.0, 107.0, 113.0, 84.0, 102.0, 86.0, 86.0, 84.0, 144.0, 108.0, 130.0, 80.0, 112.0, 87.0, 90.0, 90.0, 76.0, 64.0, 80.0, 80.0, 75.0, 114.0, 80.0, 60.0, 78.0, 77.0, 72.0, 109.0, 109.0, 109.0, 88.0, 76.0, 84.0, 80.0, 108.0, 97.0, 60.0, 84.0, 100.0, 76.0, 82.0, 64.0, 75.0, 98.0, 80.0, 88.0, 88.0, 108.0, 74.0, 80.0, 101.0, 70.0, 72.0, 84.0, 72.0, 82.0, 68.0, 95.0, 108.0, 80.0, 82.0, 75.0, 79.0, 108.0 };

	        double[] data = Arrays.stream(objectArray)
	                              .mapToDouble(Double::doubleValue)
	                              .toArray();
	        double[] ksData = Arrays.stream(listDouble.toArray(new Double[listDouble.size()])).mapToDouble(Double::doubleValue).toArray();
	        // Get a SummaryStatistics instance
	        SummaryStatistics stats = new SummaryStatistics();
	        for(double i : ksData) {
	        	stats.addValue(i);
	        }
	        _log.info("P-Value: " + listDouble);

	        double mean = stats.getMean();
	        double std = stats.getStandardDeviation();
	        
	        _log.info("Kolmogorov-Smirnov Statistic: " + mean);
	        _log.info("P-Value: " + std);
	        
	        RealDistribution distribution = new NormalDistribution(mean, std);

	        KolmogorovSmirnovTest ksTest = new KolmogorovSmirnovTest();
	        double pValue = ksTest.kolmogorovSmirnovTest(distribution, data);
	        double statistic = ksTest.kolmogorovSmirnovStatistic(distribution, data);

	        System.out.println("Kolmogorov-Smirnov Statistic: " + statistic);
	        System.out.println("P-Value: " + pValue);
			
	        /*RealDistribution distribution = new NormalDistribution(graph_avg, graph_sd);

	        //double[] data = { -1.2, -0.8, 0.0, 0.5, 1.0, 1.3 };

	        KolmogorovSmirnovTest ksTest = new KolmogorovSmirnovTest();
	        double[] ksData = Arrays.stream(listDouble.toArray(new Double[listDouble.size()])).mapToDouble(Double::doubleValue).toArray();
	        _log.info("P-Value: " + ksData);
	        _log.info("P-Value: " + listDouble);
	        double pValue = ksTest.kolmogorovSmirnovTest(distribution, ksData);
	        double statistic = ksTest.kolmogorovSmirnovStatistic(distribution, ksData);

	        _log.info("Kolmogorov-Smirnov Statistic: " + statistic);
	        _log.info("P-Value: " + pValue);*/

	        double alpha = 0.05;
			
			normality_value.add("0");
			
			JSONObject displayName = compObj.getJSONObject("displayName");
			
			renderRequest.setAttribute("type", compObj.getString("termType"));
			renderRequest.setAttribute("displayName", displayName.get("en_US"));
			renderRequest.setAttribute("statistics_name", statistics_name);
			renderRequest.setAttribute("statistics_value", statistics_value);
			renderRequest.setAttribute("quartiles_name", quartiles_name);
			renderRequest.setAttribute("quartiles_value", quartiles_value);
			renderRequest.setAttribute("normality_name", normality_name);
			renderRequest.setAttribute("normality_value", normality_value);

			return ECRFUserJspPaths.JSP_DIALOG_CRF_DATA_GRAPH;

		} else {
			return null;
		}
		
	}
	
	double exportPercentile(List<Double> data, double percentile) {

		double index = percentile * (data.size() - 1);
		int lower = (int) Math.floor(index);
		if (lower < 0) { // should never happen, but be defensive
			return data.get(0);
		}
		if (lower >= data.size() - 1) { // only in 100 percentile case, but be defensive
			return data.get(data.size() - 1);
		}
		double fraction = index - lower;
		// linear interpolation
		double result = data.get(lower) + fraction * (data.get(lower + 1) - data.get(lower));

		return result;
	}
	
	private Log _log = LogFactoryUtil.getLog(DialogGraphRenderCommand.class);
	
	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;
}

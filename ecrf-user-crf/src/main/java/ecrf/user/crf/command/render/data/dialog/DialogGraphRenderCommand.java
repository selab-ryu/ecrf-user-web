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
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.service.CRFLocalService;

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
			
			Set<String> set_datas = new LinkedHashSet<>(datas);
			List<String> fin_datas = new ArrayList<>(set_datas);
			int[] values = new int[fin_datas.size()];

			Collections.sort(fin_datas);

			for (int i = 0; i < fin_datas.size(); i++) {
				values[i] = Collections.frequency(datas, fin_datas.get(i));
			}

			List<Double> tmpIntList = datas.stream().map(Double::valueOf).collect(Collectors.toList());
			Collections.sort(tmpIntList);

			// Maximum range limited to 10
			int numberOfRange = 10;

			if(fin_datas.size() > numberOfRange) {
				List<Double> double_datas = new ArrayList<>();
				
				for(int i = 0; i < fin_datas.size(); i++) {
					double_datas.add(Double.parseDouble(fin_datas.get(i)));
				}

				double range_max = Collections.max(double_datas);
				double range_min = Collections.min(double_datas);
				double range = (range_max - range_min) / numberOfRange;
				List<String> range_datas = new ArrayList<>(); 
				int[] range_values = new int[10];
				
				for(int i = 0; i < numberOfRange; i++) {
					double lowerBound = range_min + i * range;
					double upperBound = lowerBound + range;

		            long count = double_datas.stream()
		                                   .filter(d -> d >= lowerBound && d <= upperBound)
		                                   .count();
		            range_datas.add(Double.toString(Math.round(lowerBound * 100) / 100.0) + " ~ " + Double.toString(Math.round(upperBound * 100) / 100.0));
		            range_values[i] = (int)count;
				}
				renderRequest.setAttribute("datas", range_datas.toArray(new String[range_datas.size()]));
				renderRequest.setAttribute("values", range_values);
			}
			else {
				renderRequest.setAttribute("datas", fin_datas.toArray(new String[fin_datas.size()]));
				renderRequest.setAttribute("values", values);
			}

			// List where you want to insert the default statistics entry
			List<String> statistics_name = new ArrayList<>();
			List<String> statistics_value = new ArrayList<>();
			
			statistics_name.add("Average");
			statistics_name.add("Variance");
			statistics_name.add("Standard_Deviation");
			
			// Calculate the average
			double sum = 0;

			for (double i : tmpIntList) {
				sum += i;
			}
			
			double graph_avg = (double) sum / tmpIntList.size();
			
			statistics_value.add(String.format("%.2f", graph_avg));
			
			// Calculate the variance
			sum = 0;

			for (double i : tmpIntList) {
				sum += Math.pow(i - graph_avg, 2);
			}

			double graph_var = (double) sum / tmpIntList.size();

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
			double graph_iqr_1 = exportPercentile(tmpIntList, 0.25);
			quartiles_value.add(String.format("%.2f", graph_iqr_1));
			
			double graph_median = exportPercentile(tmpIntList, 0.5);
			quartiles_value.add(String.format("%.2f", graph_median));
			
			double graph_iqr_3 = exportPercentile(tmpIntList, 0.75);
			quartiles_value.add(String.format("%.2f", graph_iqr_3));
			
			// List to insert normality test values
			List<String> normality_name = new ArrayList<>();
			List<String> normality_value = new ArrayList<>();
			
			normality_name.add("ShapiroWilk");

			// ShapiroWilk
			double shapiroWilk_value = ShapiroWilkW(tmpIntList.toArray(new Double[tmpIntList.size()]));
			
			if(shapiroWilk_value == 99.99){
				normality_value.add("n is too small!");
			}
			else if(shapiroWilk_value == 999.999){
				normality_value.add("n is too big!");
			}else{
				normality_value.add(String.format("%.2f", shapiroWilk_value));
			}
			
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

	double poly(double[] cc, int nord, double x) {
		/*
		 * Algorithm AS 181.2 Appl. Statist. (1982) Vol. 31, No. 2 Calculates the
		 * algebraic polynomial of order nord-1 with array of coefficients cc. Zero
		 * order coefficient is cc(1) = cc[0]
		 */

		double ret_val = cc[0];
		if (nord > 1) {
			double p = x * cc[nord - 1];
			for (int j = nord - 2; j > 0; --j) {
				p = (p + cc[j]) * x;
			}
			ret_val += p;
		}
		return ret_val;
	}

	/**
	 * Used internally by ShapiroWilkW()
	 * 
	 * @param x
	 * @return
	 */
	int sign(double x) {
		if (x == 0) {
			return 0;
		}
		return (x > 0) ? 1 : -1;
	}

	double normalQuantile(double p, int mu, int sigma) {
		double q, r, val;
		if (sigma < 0)
			return -1;
		if (sigma == 0)
			return mu;

		q = p - 0.5;

		if (0.075 <= p && p <= 0.925) {
			r = 0.180625 - q * q;
			val = q * (((((((r * 2509.0809287301226727 + 33430.575583588128105) * r + 67265.770927008700853) * r
					+ 45921.953931549871457) * r + 13731.693765509461125) * r + 1971.5909503065514427) * r
					+ 133.14166789178437745) * r + 3.387132872796366608)
					/ (((((((r * 5226.495278852854561 + 28729.085735721942674) * r + 39307.89580009271061) * r
							+ 21213.794301586595867) * r + 5394.1960214247511077) * r + 687.1870074920579083) * r
							+ 42.313330701600911252) * r + 1);
		} else { /* closer than 0.075 from {0,1} boundary */
			/* r = min(p, 1-p) < 0.075 */
			if (q > 0)
				r = 1 - p;
			else
				r = p;/* = R_DT_Iv(p) ^= p */

			r = Math.sqrt(-Math.log(r)); /* r = sqrt(-log(r)) <==> min(p, 1-p) = exp( - r^2 ) */

			if (r <= 5.) { /* <==> min(p,1-p) >= exp(-25) ~= 1.3888e-11 */
				r += -1.6;
				val = (((((((r * 7.7454501427834140764e-4 + 0.0227238449892691845833) * r + .24178072517745061177) * r
						+ 1.27045825245236838258) * r + 3.64784832476320460504) * r + 5.7694972214606914055) * r
						+ 4.6303378461565452959) * r + 1.42343711074968357734)
						/ (((((((r * 1.05075007164441684324e-9 + 5.475938084995344946e-4) * r + .0151986665636164571966)
								* r + 0.14810397642748007459) * r + 0.68976733498510000455) * r + 1.6763848301838038494)
								* r + 2.05319162663775882187) * r + 1);
			} else { /* very close to 0 or 1 */
				r += -5.;
				val = (((((((r * 2.01033439929228813265e-7 + 2.71155556874348757815e-5) * r + 0.0012426609473880784386)
						* r + 0.026532189526576123093) * r + .29656057182850489123) * r + 1.7848265399172913358) * r
						+ 5.4637849111641143699) * r + 6.6579046435011037772)
						/ (((((((r * 2.04426310338993978564e-15 + 1.4215117583164458887e-7) * r
								+ 1.8463183175100546818e-5) * r + 7.868691311456132591e-4) * r
								+ .0148753612908506148525) * r + .13692988092273580531) * r + .59983220655588793769) * r
								+ 1.);
			}

			if (q < 0.0)
				val = -val;
			/* return (q >= 0.)? r : -r ; */
		}
		return mu + sigma * val;
	}

	double Gauss(double z) {
		double y, p, w;

		if (z == 0.0) {
			p = 0.0;
		} else {
			y = Math.abs(z) / 2;
			if (y >= 3.0) {
				p = 1.0;
			} else if (y < 1.0) {
				w = y * y;
				p = ((((((((0.000124818987 * w - 0.001075204047) * w + 0.005198775019) * w - 0.019198292004) * w
						+ 0.059054035642) * w - 0.151968751364) * w + 0.319152932694) * w - 0.531923007300) * w
						+ 0.797884560593) * y * 2.0;
			} else {
				y = y - 2.0;
				p = (((((((((((((-0.000045255659 * y + 0.000152529290) * y - 0.000019538132) * y - 0.000676904986) * y
						+ 0.001390604284) * y - 0.000794620820) * y - 0.002034254874) * y + 0.006549791214) * y
						- 0.010557625006) * y + 0.011630447319) * y - 0.009279453341) * y + 0.005353579108) * y
						- 0.002141268741) * y + 0.000535310849) * y + 0.999936657524;
			}
		}

		if (z > 0.0) {
			return (p + 1.0) / 2;
		} else {
			return (1.0 - p) / 2;
		}
	}

	double ShapiroWilkW(Double[] x) throws IllegalArgumentException {

		int n = x.length;
		double pw = 1.0;
		if (n < 3) {
			pw = 99.99;
			return pw;
			//throw new IllegalArgumentException();
		}
		if (n > 5000) {
			// console.log("n is too big!")
			pw = 999.999;
			return pw;
			//throw new IllegalArgumentException();
		}

		int nn2 = n / 2;
		double[] a = new double[nn2 + 1]; /* 1-based */

		/*
		 * ALGORITHM AS R94 APPL. STATIST. (1995) vol.44, no.4, 547-551. Calculates the
		 * Shapiro-Wilk W test and its significance level
		 */
		double small = 1e-19;

		/* polynomial coefficients */
		double g[] = { -2.273, 0.459 };
		double c1[] = { 0.0, 0.221157, -0.147981, -2.07119, 4.434685, -2.706056 };
		double c2[] = { 0.0, 0.042981, -0.293762, -1.752461, 5.682633, -3.582633 };
		double c3[] = { 0.544, -0.39978, 0.025054, -6.714e-4 };
		double c4[] = { 1.3822, -0.77857, 0.062767, -0.0020322 };
		double c5[] = { -1.5861, -0.31082, -0.083751, 0.0038915 };
		double c6[] = { -0.4803, -0.082676, 0.0030302 };

		/* Local variables */
		int i, j, i1;

		double ssassx, summ2, ssumm2, gamma, range;
		double a1, a2, an, m, s, sa, xi, sx, xx, y, w1;
		double fac, asa, an25, ssa, sax, rsn, ssx, xsx;

		
		an = (double) n;

		if (n == 3) {
			a[1] = 0.70710678;/* = sqrt(1/2) */
		} else {
			an25 = an + 0.25;
			summ2 = 0.0;
			for (i = 1; i <= nn2; i++) {
				a[i] = normalQuantile((i - 0.375) / an25, 0, 1); // p(X <= x),
				summ2 += a[i] * a[i];
			}
			summ2 *= 2.0;
			ssumm2 = Math.sqrt(summ2);
			rsn = 1.0 / Math.sqrt(an);
			a1 = poly(c1, 6, rsn) - a[1] / ssumm2;

			/* Normalize a[] */
			if (n > 5) {
				i1 = 3;
				a2 = -a[2] / ssumm2 + poly(c2, 6, rsn);
				fac = Math.sqrt((summ2 - 2.0 * (a[1] * a[1]) - 2.0 * (a[2] * a[2]))
						/ (1.0 - 2.0 * (a1 * a1) - 2.0 * (a2 * a2)));
				a[2] = a2;
			} else {
				i1 = 2;
				fac = Math.sqrt((summ2 - 2.0 * (a[1] * a[1])) / (1.0 - 2.0 * (a1 * a1)));
			}
			a[1] = a1;
			for (i = i1; i <= nn2; i++) {
				a[i] /= -fac;
			}
		}

		/* Check for zero range */

		range = x[n - 1] - x[0];
		if (range < small) {
			// console.log('range is too small!');
			throw new IllegalArgumentException();
		}

		/* Check for correct sort order on range - scaled X */

		xx = x[0] / range;
		sx = xx;
		sa = -a[1];
		for (i = 1, j = n - 1; i < n; j--) {
			xi = x[i] / range;
			if (xx - xi > small) {
				// console.log("xx - xi is too big.", xx - xi);
				throw new IllegalArgumentException();
			}
			sx += xi;
			i++;
			if (i != j) {
				sa += sign(i - j) * a[Math.min(i, j)];
			}
			xx = xi;
		}

		/* Calculate W statistic as squared correlation between data and coefficients */

		sa /= n;
		sx /= n;
		ssa = ssx = sax = 0.;
		for (i = 0, j = n - 1; i < n; i++, j--) {
			if (i != j) {
				asa = sign(i - j) * a[1 + Math.min(i, j)] - sa;
			} else {
				asa = -sa;
			}
			xsx = x[i] / range - sx;
			ssa += asa * asa;
			ssx += xsx * xsx;
			sax += asa * xsx;
		}

		/*
		 * W1 equals (1-W) calculated to avoid excessive rounding error for W very near
		 * 1 (a potential problem in very large samples)
		 */

		ssassx = Math.sqrt(ssa * ssx);
		w1 = (ssassx - sax) * (ssassx + sax) / (ssa * ssx);
		double w = 1.0 - w1;
		_log.info("w =" + w);
		/* Calculate significance level for W */

		if (n == 3) {/* exact P value : */
			double pi6 = 1.90985931710274; /* = 6/pi */
			double stqr = 1.04719755119660; /* = asin(sqrt(3/4)) */
			pw = pi6 * (Math.asin(Math.sqrt(w)) - stqr);
			if (pw < 0.) {
				pw = 0;
			}
			// return w;
			return pw;
		}
		y = Math.log(w1);
		xx = Math.log(an);
		if (n <= 11) {
			gamma = poly(g, 2, an);
			if (y >= gamma) {
				pw = 1e-99; /* an "obvious" value, was 'small' which was 1e-19f */
				// return w;
				return pw;
			}
			y = -Math.log(gamma - y);
			m = poly(c3, 4, an);
			s = Math.exp(poly(c4, 4, an));
		} else { /* n >= 12 */
			m = poly(c5, 4, xx);
			s = Math.exp(poly(c6, 3, xx));
		}

		// Oops, we don't have pnorm
		// pw = pnorm(y, m, s, 0/* upper tail */, 0);
		double z = (y - m) / s;
		_log.info("z =" + z);
		pw = Gauss(z);
		// return w;
		return pw;
	}
	
	private Log _log = LogFactoryUtil.getLog(DialogGraphRenderCommand.class);
	
	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;
}

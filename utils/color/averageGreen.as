package utils.color
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;

	/**
	 * Sample &amp; average the <i>Green</i> (RGB) value from a display object or one of its region.
	 *
	 * @param src The DisplayObject
	 * @param accuracy Percentage of pixels to sample when averaging.
	 * @param region to sample from [Default: null = entire src object].
	 * @return the sampled average <i>green</i> value on a scale of 0-255.
	 */
	public function averageGreen(src:DisplayObject, accuracy:Number = 0.01, region:Rectangle = null):int
	{
		return averageColorProperty(src, region, accuracy, 'g');
	}
}
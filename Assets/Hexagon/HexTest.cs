using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HexTest : MonoBehaviour
{
    [SerializeField]
    RenderTexture mRenderTexture;

    [SerializeField]
    Material mMaterial;

    [SerializeField]
    int mAlphaSplitNum = 10;

    [SerializeField]
    float mPointScale = 0.1f;

    [SerializeField]
    Color mPointColor;

    int mCurrentAlphaNum = 0;

    float[] results = null;

    // Start is called before the first frame update
    void Start()
    {
        results = new float[mAlphaSplitNum + 1] ;
    }

    // Update is called once per frame
    void Update()
    {
        if(mCurrentAlphaNum > mAlphaSplitNum)
        {
            mCurrentAlphaNum = 0;
            return;
        }

        mMaterial.SetFloat("_TestLum", 1.0f / mAlphaSplitNum * mCurrentAlphaNum);

        Graphics.Blit(null, mRenderTexture, mMaterial);

        RenderTexture.active = mRenderTexture;

        Texture2D tex = new Texture2D(mRenderTexture.width, mRenderTexture.height);
        tex.ReadPixels(new Rect(0, 0, tex.width, tex.height), 0, 0);
        tex.Apply();

        int count = 0;
        for(int x = 0; x < tex.width; x++)
        {
            for(int y = 0; y < tex.height; y++)
            {
                if(tex.GetPixel(x, y).r < 0.5f)
                {
                    count++;
                }
            }
        }

        float rate = (float)count / (tex.width * tex.height);
        Debug.Log("num = " + mCurrentAlphaNum + " : rate = " + ( rate * 100.0f ));

        results[mCurrentAlphaNum] = rate;

        mCurrentAlphaNum++;
    }

    void OnDrawGizmos()
    {
        if(results == null)
        {
            return;
        }

        Gizmos.color = mPointColor;
        for (int i = 0; i <= mAlphaSplitNum; i++)
        {
            Gizmos.DrawCube(new Vector3(1.0f / mAlphaSplitNum * i, (float)i / mAlphaSplitNum, 0.0f), Vector3.one * mPointScale);
            Gizmos.DrawCube(new Vector3(1.0f / mAlphaSplitNum * i, results[i], 0.0f), Vector3.one * mPointScale);
        }
    }
}

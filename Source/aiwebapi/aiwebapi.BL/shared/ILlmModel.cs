﻿namespace aiwebapi.BL.shared;

public interface ILlmModel
{
    string ModelName { get; }
    string Provider { get; }
    Task<string> QueryAsync(string prompt);
}